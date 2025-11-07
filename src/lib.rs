// SPDX-License-Identifier: GPL-3.0-only

mod window;

use window::Window;

pub fn run() -> cosmic::iced::Result {
    cosmic::applet::run::<Window>(())
}
