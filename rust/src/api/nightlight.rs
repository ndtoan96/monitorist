#[cfg(target_os = "windows")]
use sem_reg::cloud_store::night_light::{self, NightLight};

#[cfg(target_os = "windows")]
type NightlightResult<T> = Result<T, night_light::Error>;

#[cfg(not(target_os = "windows"))]
#[derive(Debug, thiserror::Error)]
#[error("Nightlight is not supported on this platform")]
pub struct NightlightUnsupportedError;

#[cfg(not(target_os = "windows"))]
type NightlightResult<T> = Result<T, NightlightUnsupportedError>;

#[flutter_rust_bridge::frb(sync)]
#[cfg(target_os = "windows")]
pub fn load_settings() -> NightlightResult<(Option<f32>, bool)> {
    let nightlight = NightLight::from_reg()?;
    Ok((nightlight.warmth(), nightlight.active()))
}

#[flutter_rust_bridge::frb(sync)]
#[cfg(not(target_os = "windows"))]
pub fn load_settings() -> NightlightResult<(Option<f32>, bool)> {
    Ok((None, false))
}

#[flutter_rust_bridge::frb(sync)]
#[cfg(target_os = "windows")]
pub fn set_warmth(warm: f32) -> NightlightResult<()> {
    let mut nightlight = NightLight::from_reg()?;
    nightlight.set_warmth(Some(warm));
    nightlight.set_night_preview_active(true);
    nightlight.write_to_reg()
}

#[flutter_rust_bridge::frb(sync)]
#[cfg(not(target_os = "windows"))]
pub fn set_warmth(_warm: f32) -> NightlightResult<()> {
    Ok(())
}

#[flutter_rust_bridge::frb(sync)]
#[cfg(target_os = "windows")]
pub fn set_active(is_active: bool) -> NightlightResult<()> {
    let mut nightlight = NightLight::from_reg()?;
    nightlight.set_night_preview_active(false);
    nightlight.write_to_reg()?;
    let mut night_light = NightLight::from_reg()?;
    night_light.set_active(is_active);
    night_light.write_to_reg()
}

#[flutter_rust_bridge::frb(sync)]
#[cfg(not(target_os = "windows"))]
pub fn set_active(_is_active: bool) -> NightlightResult<()> {
    Ok(())
}
