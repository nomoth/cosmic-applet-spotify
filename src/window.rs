use cosmic::app::Core;
use cosmic::iced::id;
use cosmic::iced::Subscription;
use cosmic::widget::autosize::autosize;
use cosmic::Element;
use mpris::{PlaybackStatus, Player, PlayerFinder};
use std::sync::LazyLock;
use std::time::Duration;
use tokio::time;

const APP_ID: &str = "com.github.cosmic-applet-spotify";
const POLL_INTERVAL_MS: u64 = 500;

static AUTOSIZE_MAIN_ID: LazyLock<id::Id> = LazyLock::new(|| id::Id::new(APP_ID));

#[derive(Debug, Clone)]
pub enum Message {
    UpdateTrack(Option<TrackInfo>),
}

#[derive(Debug, Clone)]
pub struct TrackInfo {
    pub title: String,
    pub artist: String,
    pub is_playing: bool,
}

pub struct Window {
    core: Core,
    current_track: Option<TrackInfo>,
}

impl cosmic::Application for Window {
    type Executor = cosmic::executor::Default;
    type Flags = ();
    type Message = Message;
    const APP_ID: &'static str = APP_ID;

    fn core(&self) -> &Core {
        &self.core
    }

    fn core_mut(&mut self) -> &mut Core {
        &mut self.core
    }

    fn init(core: Core, _flags: Self::Flags) -> (Self, cosmic::app::Task<Self::Message>) {
        let applet = Self {
            core,
            current_track: None,
        };
        (applet, cosmic::app::Task::none())
    }

    fn update(&mut self, message: Self::Message) -> cosmic::app::Task<Self::Message> {
        match message {
            Message::UpdateTrack(track) => {
                self.current_track = track;
            }
        }
        cosmic::app::Task::none()
    }

    fn view(&self) -> Element<'_, Self::Message> {
        let content = if let Some(track) = &self.current_track {
            let icon = if track.is_playing { "♫" } else { "‖" };
            format!("{} {} - {}", icon, track.artist, track.title)
        } else {
            "‖".to_string()
        };

        let suggested_padding = self.core.applet.suggested_padding(true);

        let button = cosmic::widget::button::custom(self.core.applet.text(content))
            .padding([0, suggested_padding])
            .class(cosmic::theme::Button::AppletIcon);

        autosize(button, AUTOSIZE_MAIN_ID.clone()).into()
    }

    fn subscription(&self) -> Subscription<Self::Message> {
        struct SpotifyWorker;

        Subscription::run_with_id(
            std::any::TypeId::of::<SpotifyWorker>(),
            async_stream::stream! {
                loop {
                    // Try to connect and retrieve track info
                    let track_info = match PlayerFinder::new() {
                        Ok(finder) => match finder.find_by_name("Spotify") {
                            Ok(player) => get_track_info(&player),
                            Err(e) => {
                                tracing::debug!("Spotify not found: {}", e);
                                None
                            }
                        }
                        Err(e) => {
                            tracing::debug!("MPRIS error: {}", e);
                            None
                        }
                    };

                    yield Message::UpdateTrack(track_info);

                    // Wait before next update
                    time::sleep(Duration::from_millis(POLL_INTERVAL_MS)).await;
                }
            },
        )
    }

    fn style(&self) -> Option<cosmic::iced_runtime::Appearance> {
        Some(cosmic::applet::style())
    }
}

fn get_track_info(player: &Player) -> Option<TrackInfo> {
    let metadata = player.get_metadata().ok()?;
    let status = player.get_playback_status().ok()?;

    let title = metadata.title().unwrap_or("Unknown Title").to_string();
    let artist = metadata
        .artists()
        .and_then(|a| a.first().map(|s| &**s))
        .unwrap_or("Unknown Artist")
        .to_string();

    let is_playing = matches!(status, PlaybackStatus::Playing);

    Some(TrackInfo {
        title,
        artist,
        is_playing,
    })
}
