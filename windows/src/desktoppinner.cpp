// SPDX-License-Identifier: GPL-3.0-or-later

#include "desktoppinner.h"

#ifdef Q_OS_WIN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>

#include <dwmapi.h>

#include <cwchar>
#include <iterator>
#endif

#ifdef Q_OS_WIN
namespace
{
DesktopPinner *s_instance = nullptr;
HWINEVENTHOOK s_foregroundHook = nullptr;

bool isDesktopWindow(HWND hwnd)
{
    wchar_t name[16] = {};
    if (!hwnd || GetClassNameW(hwnd, name, int(std::size(name))) == 0) {
        return false;
    }
    return std::wcscmp(name, L"WorkerW") == 0 || std::wcscmp(name, L"Progman") == 0;
}

bool belongsToThisProcess(HWND hwnd)
{
    DWORD processId = 0;
    GetWindowThreadProcessId(hwnd, &processId);
    return processId == GetCurrentProcessId();
}

bool isCloaked(HWND hwnd)
{
    BOOL cloaked = FALSE;
    return SUCCEEDED(DwmGetWindowAttribute(hwnd, DWMWA_CLOAKED, &cloaked, sizeof(cloaked))) && cloaked;
}

// Whether a normal application window is still shown above the desktop,
// as when the user just clicks the wallpaper instead of showing the desktop.
bool applicationWindowAbove(HWND desktop)
{
    for (HWND hwnd = GetTopWindow(nullptr); hwnd && hwnd != desktop; hwnd = GetWindow(hwnd, GW_HWNDNEXT)) {
        if (!IsWindowVisible(hwnd) || IsIconic(hwnd) || isCloaked(hwnd) || belongsToThisProcess(hwnd)) {
            continue;
        }
        // Skip the taskbar, tooltips and other tool or topmost windows.
        const LONG_PTR exStyle = GetWindowLongPtrW(hwnd, GWL_EXSTYLE);
        if (exStyle & (WS_EX_TOOLWINDOW | WS_EX_TOPMOST | WS_EX_NOACTIVATE)) {
            continue;
        }
        RECT rect;
        if (GetWindowRect(hwnd, &rect) && rect.right - rect.left > 1 && rect.bottom - rect.top > 1) {
            return true;
        }
    }
    return false;
}

void CALLBACK onForegroundChanged(HWINEVENTHOOK, DWORD, HWND, LONG idObject, LONG, DWORD, DWORD)
{
    if (s_instance && idObject == OBJID_WINDOW) {
        // Windows may still be rearranging; check once the event loop is back.
        QMetaObject::invokeMethod(s_instance, "updateZOrder", Qt::QueuedConnection);
    }
}
} // namespace
#endif

DesktopPinner::DesktopPinner(QObject *parent)
    : QObject(parent)
{
#ifdef Q_OS_WIN
    s_instance = this;
    s_foregroundHook = SetWinEventHook(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, nullptr, onForegroundChanged, 0, 0, WINEVENT_OUTOFCONTEXT);
#endif
}

DesktopPinner::~DesktopPinner()
{
#ifdef Q_OS_WIN
    if (s_foregroundHook) {
        UnhookWinEvent(s_foregroundHook);
        s_foregroundHook = nullptr;
    }
    s_instance = nullptr;
#endif
}

void DesktopPinner::pin(QWindow *window)
{
    if (!window) {
        return;
    }
    m_windows.append(window);
#ifdef Q_OS_WIN
    // Also stay visible while the user peeks at the desktop.
    const HWND hwnd = reinterpret_cast<HWND>(window->winId());
    BOOL excluded = TRUE;
    DwmSetWindowAttribute(hwnd, DWMWA_EXCLUDED_FROM_PEEK, &excluded, sizeof(excluded));
#endif
}

void DesktopPinner::updateZOrder()
{
#ifdef Q_OS_WIN
    m_windows.removeAll(nullptr);

    const HWND foreground = GetForegroundWindow();
    if (!foreground || belongsToThisProcess(foreground)) {
        // A countdown or the settings dialog: keep the current order.
        return;
    }
    const bool raise = isDesktopWindow(foreground) && !applicationWindowAbove(foreground);
    if (raise == m_raised) {
        return;
    }
    m_raised = raise;

    const UINT flags = SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE;
    for (const QPointer<QWindow> &window : std::as_const(m_windows)) {
        const HWND hwnd = reinterpret_cast<HWND>(window->winId());
        if (raise) {
            ShowWindow(hwnd, SW_SHOWNOACTIVATE);
            SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, flags | SWP_SHOWWINDOW);
        } else {
            SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, flags);
            SetWindowPos(hwnd, HWND_BOTTOM, 0, 0, 0, 0, flags);
        }
    }
#endif
}
