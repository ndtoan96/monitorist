use sem_reg::cloud_store::night_light::{self, NightLight};

#[flutter_rust_bridge::frb(sync)]
pub fn load_settings() -> Result<(Option<f32>, bool), night_light::Error> {
    let nightlight = NightLight::from_reg()?;
    Ok((nightlight.warmth(), nightlight.active()))
}

#[flutter_rust_bridge::frb(sync)]
pub fn set_warmth(warm: f32) -> Result<(), night_light::Error> {
    let mut nightlight = NightLight::from_reg()?;
    nightlight.set_warmth(Some(warm));
    nightlight.set_night_preview_active(true);
    nightlight.write_to_reg()
}

#[flutter_rust_bridge::frb(sync)]
pub fn set_active(is_active: bool) -> Result<(), night_light::Error> {
    let mut nightlight = NightLight::from_reg()?;
    nightlight.set_night_preview_active(false);
    nightlight.write_to_reg()?;
    let mut night_light = NightLight::from_reg()?;
    night_light.set_active(is_active);
    night_light.write_to_reg()
}
