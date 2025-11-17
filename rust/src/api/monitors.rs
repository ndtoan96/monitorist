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

    pub async fn device_name(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_name().await?)
    }

    pub async fn friendly_device_name(&self) -> Result<String, brightness::Error> {
        Ok(self.0.friendly_device_name().await?)
    }

    pub fn device_description(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_description()?)
    }

    pub fn device_path(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_path()?)
    }

    pub async fn get_brightness(&self) -> Result<u32, brightness::Error> {
        Ok(self.0.get().await?)
    }

    pub async fn set_brightness(&mut self, value: u32) -> Result<(), brightness::Error> {
        Ok(self.0.set(value).await?)
    }
}
