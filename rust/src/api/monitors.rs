#[cfg(target_os = "windows")]
use brightness::windows::BrightnessExt;
use brightness::{Brightness, BrightnessDevice};
use futures::StreamExt;
use std::io::{Error as IoError, ErrorKind};

pub struct MonitorResult {
    pub success: Option<Monitor>,
    pub fail: Option<String>,
}

pub struct Monitor(BrightnessDevice);

impl Monitor {
    #[cfg(not(target_os = "windows"))]
    fn unsupported_device_info() -> brightness::Error {
        brightness::Error::GettingDeviceInfo {
            device: "unknown".to_string(),
            source: Box::new(IoError::new(
                ErrorKind::Unsupported,
                "This monitor property is only available on Windows",
            )),
        }
    }

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
            self.device_name().await
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
    #[cfg(target_os = "windows")]
    pub fn device_description(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_description()?)
    }

    #[flutter_rust_bridge::frb(sync)]
    #[cfg(not(target_os = "windows"))]
    pub fn device_description(&self) -> Result<String, brightness::Error> {
        Err(Self::unsupported_device_info())
    }

    #[flutter_rust_bridge::frb(sync)]
    #[cfg(target_os = "windows")]
    pub fn device_path(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_path()?)
    }

    #[flutter_rust_bridge::frb(sync)]
    #[cfg(not(target_os = "windows"))]
    pub fn device_path(&self) -> Result<String, brightness::Error> {
        futures::executor::block_on(self.0.device_name())
    }

    #[flutter_rust_bridge::frb(sync)]
    #[cfg(target_os = "windows")]
    pub fn device_registry_key(&self) -> Result<String, brightness::Error> {
        Ok(self.0.device_registry_key()?)
    }

    #[flutter_rust_bridge::frb(sync)]
    #[cfg(not(target_os = "windows"))]
    pub fn device_registry_key(&self) -> Result<String, brightness::Error> {
        Err(Self::unsupported_device_info())
    }

    pub async fn get_brightness(&self) -> Result<u32, brightness::Error> {
        Ok(self.0.get().await?)
    }

    pub async fn set_brightness(&mut self, value: u32) -> Result<(), brightness::Error> {
        Ok(self.0.set(value).await?)
    }
}
