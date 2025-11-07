// SPDX-License-Identifier: MIT

const VERSION: &str = env!("CARGO_PKG_VERSION");

fn main() -> cosmic::iced::Result {
    tracing_subscriber::fmt::init();
    let _ = tracing_log::LogTracer::init();

    tracing::info!("Starting cosmic-applet-spotify with version {VERSION}");

    cosmic_applet_spotify::run()
}
