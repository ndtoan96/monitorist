use sem_reg::cloud_store::night_light::{self, NightLight};

#[flutter_rust_bridge::frb(sync)]
pub fn load_settings() -> Result<(Option<f32>, bool), night_light::Error> {
    let nightlight = NightLight::from_reg()?;
    Ok((nightlight.warmth().map(|x| x * 100.0), nightlight.active()))
}

#[flutter_rust_bridge::frb(sync)]
pub fn set_warmth(strength: f32) -> Result<(), night_light::Error> {
    let mut nightlight = NightLight::from_reg()?;
    nightlight.set_warmth(Some(strength / 100.0));
    nightlight.set_night_preview_active(true);
    nightlight.write_to_reg()
}

#[flutter_rust_bridge::frb(sync)]
pub fn set_active(is_active: bool) -> Result<(), night_light::Error> {
    let mut nightlight = NightLight::from_reg()?;
    nightlight.set_active(is_active);
    nightlight.write_to_reg()
}
