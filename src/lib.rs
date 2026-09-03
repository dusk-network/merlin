#![cfg_attr(not(feature = "std"), no_std)]
#![doc = include_str!("../README.md")]
#![doc(html_root_url = "https://docs.rs/merlin/3.0.0")]

#[cfg(target_endian = "big")]
compile_error!(
    r#"
This crate doesn't support big-endian targets, since I didn't
have one to test correctness on.  If you're seeing this message,
please file an issue!
"#
);

mod constants;
mod strobe;
mod transcript;

pub use crate::transcript::Transcript;
pub use crate::transcript::TranscriptRng;
pub use crate::transcript::TranscriptRngBuilder;
