use brightness::{windows::BrightnessExt, Brightness, BrightnessDevice};
use futures::StreamExt;

pub struct MonitorResult {
    pub success: Option<Monitor>,
    pub fail: Option<String>,
}

pub struct Monitor(BrightnessDevice);

impl Monitor {
    pub async fn get_monitors() -> Vec<MonitorResult> {
        brightness::brightness_devices()
            .map(|dev_result| match dev_result {
                Ok(dev) => MonitorResult {
                    success: Some(Monitor(dev)),
                    fail: None,
                },
                Err(e) => MonitorResult {
                    success: None,
                    fail: Some(e.to_string()),
                },
            })
            .collect()
            .await
    }

    pub async fn display_name(&self) -> Result<String, brightness::Error> {
        let friendly_name = self.friendly_device_name().await?;
        if friendly_name.is_empty() {
            let description = self.device_description()?;
            if description.is_empty() {
                self.device_name().await
            } else {
                Ok(description)
            }
        } else {
            Ok(friendly_name)
        }
    }

    pub async fn device_name(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_name().await?)
    }

    pub async fn friendly_device_name(&self) -> Result<String, brightness::Error> {
        Ok(self.0.friendly_device_name().await?)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn device_description(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_description()?)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn device_path(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_path()?)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn device_registry_key(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_registry_key()?)
    }

    pub async fn get_brightness(&self) -> Result<u32, brightness::Error> {
        Ok(self.0.get().await?)
    }

    pub async fn set_brightness(&mut self, value: u32) -> Result<(), brightness::Error> {
        Ok(self.0.set(value).await?)
    }
}
