#![allow(
    non_camel_case_types,
    unused,
    non_snake_case,
    clippy::needless_return,
    clippy::redundant_closure_call,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::unused_unit,
    clippy::double_parens,
    clippy::let_and_return,
    clippy::too_many_arguments,
    clippy::match_single_binding,
    clippy::clone_on_copy,
    clippy::let_unit_value,
    clippy::deref_addrof,
    clippy::explicit_auto_deref,
    clippy::borrow_deref_ref,
    clippy::uninlined_format_args,
    clippy::needless_borrow,
    mismatched_lifetime_syntaxes
)]

// Section: imports

use crate::api::*;
use flutter_rust_bridge::for_generated::byteorder::{NativeEndian, ReadBytesExt, WriteBytesExt};
use flutter_rust_bridge::for_generated::{Lifetimeable, Lockable, transform_result_dco};
use flutter_rust_bridge::{Handler, IntoIntoDart};

// Section: boilerplate

flutter_rust_bridge::frb_generated_boilerplate!(
    default_stream_sink_codec = SseCodec,
    default_rust_opaque = RustOpaqueMoi,
    default_rust_auto_opaque = RustAutoOpaqueMoi,
);
pub(crate) const FLUTTER_RUST_BRIDGE_CODEGEN_VERSION: &str = "2.13.0";
pub(crate) const FLUTTER_RUST_BRIDGE_CODEGEN_CONTENT_HASH: i32 = -689688626;

// Section: executor

flutter_rust_bridge::frb_generated_default_handler!();

// Section: wire_funcs

fn wire__crate__api__Vault_close_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_close",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let mut api_that_guard = None;
                    let decode_indices_ =
                        flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                            flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                                &api_that, 0, false,
                            ),
                        ]);
                    for i in decode_indices_ {
                        match i {
                            0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                            _ => unreachable!(),
                        }
                    }
                    let api_that_guard = api_that_guard.unwrap();
                    let output_ok = crate::api::Vault::close(&*api_that_guard)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_confirm_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_confirm",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            let api_answers = <Vec<String>>::sse_decode(&mut deserializer);
            let api_generation = <u64>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let mut api_that_guard = None;
                    let decode_indices_ =
                        flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                            flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                                &api_that, 0, false,
                            ),
                        ]);
                    for i in decode_indices_ {
                        match i {
                            0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                            _ => unreachable!(),
                        }
                    }
                    let api_that_guard = api_that_guard.unwrap();
                    let output_ok =
                        crate::api::Vault::confirm(&*api_that_guard, api_answers, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_generation_impl(
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) -> flutter_rust_bridge::for_generated::WireSyncRust2DartSse {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_sync::<flutter_rust_bridge::for_generated::SseCodec, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_generation",
            port: None,
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Sync,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            deserializer.end();
            transform_result_sse::<_, ()>((move || {
                let mut api_that_guard = None;
                let decode_indices_ =
                    flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                        flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                            &api_that, 0, false,
                        ),
                    ]);
                for i in decode_indices_ {
                    match i {
                        0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                        _ => unreachable!(),
                    }
                }
                let api_that_guard = api_that_guard.unwrap();
                let output_ok = Ok::<_, ()>(crate::api::Vault::generation(&*api_that_guard))?;
                std::result::Result::Ok(output_ok)
            })())
        },
    )
}
fn wire__crate__api__Vault_lock_impl(
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) -> flutter_rust_bridge::for_generated::WireSyncRust2DartSse {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_sync::<flutter_rust_bridge::for_generated::SseCodec, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_lock",
            port: None,
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Sync,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            deserializer.end();
            transform_result_sse::<_, crate::api::VaultFailure>((move || {
                let mut api_that_guard = None;
                let decode_indices_ =
                    flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                        flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                            &api_that, 0, false,
                        ),
                    ]);
                for i in decode_indices_ {
                    match i {
                        0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                        _ => unreachable!(),
                    }
                }
                let api_that_guard = api_that_guard.unwrap();
                let output_ok = crate::api::Vault::lock(&*api_that_guard)?;
                std::result::Result::Ok(output_ok)
            })())
        },
    )
}
fn wire__crate__api__Vault_open_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_open",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_directory = <String>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let output_ok = crate::api::Vault::open(api_directory)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_prepare_creation_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_prepare_creation",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            let api_password = <String>::sse_decode(&mut deserializer);
            let api_generation = <u64>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let mut api_that_guard = None;
                    let decode_indices_ =
                        flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                            flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                                &api_that, 0, false,
                            ),
                        ]);
                    for i in decode_indices_ {
                        match i {
                            0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                            _ => unreachable!(),
                        }
                    }
                    let api_that_guard = api_that_guard.unwrap();
                    let output_ok = crate::api::Vault::prepare_creation(
                        &*api_that_guard,
                        api_password,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_prepare_recovery_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_prepare_recovery",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            let api_phrase = <String>::sse_decode(&mut deserializer);
            let api_password = <String>::sse_decode(&mut deserializer);
            let api_generation = <u64>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let mut api_that_guard = None;
                    let decode_indices_ =
                        flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                            flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                                &api_that, 0, false,
                            ),
                        ]);
                    for i in decode_indices_ {
                        match i {
                            0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                            _ => unreachable!(),
                        }
                    }
                    let api_that_guard = api_that_guard.unwrap();
                    let output_ok = crate::api::Vault::prepare_recovery(
                        &*api_that_guard,
                        api_phrase,
                        api_password,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_status_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_status",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let mut api_that_guard = None;
                    let decode_indices_ =
                        flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                            flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                                &api_that, 0, false,
                            ),
                        ]);
                    for i in decode_indices_ {
                        match i {
                            0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                            _ => unreachable!(),
                        }
                    }
                    let api_that_guard = api_that_guard.unwrap();
                    let output_ok = crate::api::Vault::status(&*api_that_guard)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_unlock_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_unlock",
            port: Some(port_),
            mode: flutter_rust_bridge::for_generated::FfiCallMode::Normal,
        },
        move || {
            let message = unsafe {
                flutter_rust_bridge::for_generated::Dart2RustMessageSse::from_wire(
                    ptr_,
                    rust_vec_len_,
                    data_len_,
                )
            };
            let mut deserializer =
                flutter_rust_bridge::for_generated::SseDeserializer::new(message);
            let api_that = <RustOpaqueMoi<
                flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
            >>::sse_decode(&mut deserializer);
            let api_password = <String>::sse_decode(&mut deserializer);
            let api_generation = <u64>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let mut api_that_guard = None;
                    let decode_indices_ =
                        flutter_rust_bridge::for_generated::lockable_compute_decode_order(vec![
                            flutter_rust_bridge::for_generated::LockableOrderInfo::new(
                                &api_that, 0, false,
                            ),
                        ]);
                    for i in decode_indices_ {
                        match i {
                            0 => api_that_guard = Some(api_that.lockable_decode_sync_ref()),
                            _ => unreachable!(),
                        }
                    }
                    let api_that_guard = api_that_guard.unwrap();
                    let output_ok =
                        crate::api::Vault::unlock(&*api_that_guard, api_password, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}

// Section: related_funcs

flutter_rust_bridge::frb_generated_moi_arc_impl_value!(
    flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>
);

// Section: dart2rust

impl SseDecode for Vault {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <RustOpaqueMoi<
            flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>,
        >>::sse_decode(deserializer);
        return flutter_rust_bridge::for_generated::rust_auto_opaque_decode_owned(inner);
    }
}

impl SseDecode for RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <usize>::sse_decode(deserializer);
        return decode_rust_opaque_moi(inner);
    }
}

impl SseDecode for String {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <Vec<u8>>::sse_decode(deserializer);
        return String::from_utf8(inner).unwrap();
    }
}

impl SseDecode for i32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_i32::<NativeEndian>().unwrap()
    }
}

impl SseDecode for Vec<String> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<String>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<u32> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<u32>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<u8> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<u8>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for crate::api::RecoveryChallenge {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_words = <Vec<String>>::sse_decode(deserializer);
        let mut var_positions = <Vec<u32>>::sse_decode(deserializer);
        return crate::api::RecoveryChallenge {
            words: var_words,
            positions: var_positions,
        };
    }
}

impl SseDecode for u32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u32::<NativeEndian>().unwrap()
    }
}

impl SseDecode for u64 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u64::<NativeEndian>().unwrap()
    }
}

impl SseDecode for u8 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u8().unwrap()
    }
}

impl SseDecode for () {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {}
}

impl SseDecode for usize {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u64::<NativeEndian>().unwrap() as _
    }
}

impl SseDecode for crate::api::VaultFailure {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::VaultFailure::Credentials,
            1 => crate::api::VaultFailure::InvalidPassword,
            2 => crate::api::VaultFailure::InvalidPhrase,
            3 => crate::api::VaultFailure::Confirmation,
            4 => crate::api::VaultFailure::Exists,
            5 => crate::api::VaultFailure::Missing,
            6 => crate::api::VaultFailure::Locked,
            7 => crate::api::VaultFailure::Busy,
            8 => crate::api::VaultFailure::Unsupported,
            9 => crate::api::VaultFailure::Corrupt,
            10 => crate::api::VaultFailure::Storage,
            11 => crate::api::VaultFailure::Stale,
            12 => crate::api::VaultFailure::Closed,
            13 => crate::api::VaultFailure::Unavailable,
            14 => crate::api::VaultFailure::WriteUncertain,
            _ => unreachable!("Invalid variant for VaultFailure: {}", inner),
        };
    }
}

impl SseDecode for crate::api::VaultStatus {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::VaultStatus::Missing,
            1 => crate::api::VaultStatus::Locked,
            2 => crate::api::VaultStatus::Unlocked,
            3 => crate::api::VaultStatus::Confirmation,
            _ => unreachable!("Invalid variant for VaultStatus: {}", inner),
        };
    }
}

impl SseDecode for bool {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u8().unwrap() != 0
    }
}

fn pde_ffi_dispatcher_primary_impl(
    func_id: i32,
    port: flutter_rust_bridge::for_generated::MessagePort,
    ptr: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len: i32,
    data_len: i32,
) {
    // Codec=Pde (Serialization + dispatch), see doc to use other codecs
    match func_id {
        1 => wire__crate__api__Vault_close_impl(port, ptr, rust_vec_len, data_len),
        2 => wire__crate__api__Vault_confirm_impl(port, ptr, rust_vec_len, data_len),
        5 => wire__crate__api__Vault_open_impl(port, ptr, rust_vec_len, data_len),
        6 => wire__crate__api__Vault_prepare_creation_impl(port, ptr, rust_vec_len, data_len),
        7 => wire__crate__api__Vault_prepare_recovery_impl(port, ptr, rust_vec_len, data_len),
        8 => wire__crate__api__Vault_status_impl(port, ptr, rust_vec_len, data_len),
        9 => wire__crate__api__Vault_unlock_impl(port, ptr, rust_vec_len, data_len),
        _ => unreachable!(),
    }
}

fn pde_ffi_dispatcher_sync_impl(
    func_id: i32,
    ptr: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len: i32,
    data_len: i32,
) -> flutter_rust_bridge::for_generated::WireSyncRust2DartSse {
    // Codec=Pde (Serialization + dispatch), see doc to use other codecs
    match func_id {
        3 => wire__crate__api__Vault_generation_impl(ptr, rust_vec_len, data_len),
        4 => wire__crate__api__Vault_lock_impl(ptr, rust_vec_len, data_len),
        _ => unreachable!(),
    }
}

// Section: rust2dart

// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for FrbWrapper<Vault> {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        flutter_rust_bridge::for_generated::rust_auto_opaque_encode::<_, MoiArc<_>>(self.0)
            .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for FrbWrapper<Vault> {}

impl flutter_rust_bridge::IntoIntoDart<FrbWrapper<Vault>> for Vault {
    fn into_into_dart(self) -> FrbWrapper<Vault> {
        self.into()
    }
}

// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::RecoveryChallenge {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.words.into_into_dart().into_dart(),
            self.positions.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::RecoveryChallenge {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::RecoveryChallenge>
    for crate::api::RecoveryChallenge
{
    fn into_into_dart(self) -> crate::api::RecoveryChallenge {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::VaultFailure {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Credentials => 0.into_dart(),
            Self::InvalidPassword => 1.into_dart(),
            Self::InvalidPhrase => 2.into_dart(),
            Self::Confirmation => 3.into_dart(),
            Self::Exists => 4.into_dart(),
            Self::Missing => 5.into_dart(),
            Self::Locked => 6.into_dart(),
            Self::Busy => 7.into_dart(),
            Self::Unsupported => 8.into_dart(),
            Self::Corrupt => 9.into_dart(),
            Self::Storage => 10.into_dart(),
            Self::Stale => 11.into_dart(),
            Self::Closed => 12.into_dart(),
            Self::Unavailable => 13.into_dart(),
            Self::WriteUncertain => 14.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::VaultFailure {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::VaultFailure> for crate::api::VaultFailure {
    fn into_into_dart(self) -> crate::api::VaultFailure {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::VaultStatus {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Missing => 0.into_dart(),
            Self::Locked => 1.into_dart(),
            Self::Unlocked => 2.into_dart(),
            Self::Confirmation => 3.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::VaultStatus {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::VaultStatus> for crate::api::VaultStatus {
    fn into_into_dart(self) -> crate::api::VaultStatus {
        self
    }
}

impl SseEncode for Vault {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>>>::sse_encode(
            flutter_rust_bridge::for_generated::rust_auto_opaque_encode::<_, MoiArc<_>>(self),
            serializer,
        );
    }
}

impl SseEncode for RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        let (ptr, size) = self.sse_encode_raw();
        <usize>::sse_encode(ptr, serializer);
        <i32>::sse_encode(size, serializer);
    }
}

impl SseEncode for String {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<u8>>::sse_encode(self.into_bytes(), serializer);
    }
}

impl SseEncode for i32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_i32::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for Vec<String> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <String>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<u32> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <u32>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<u8> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <u8>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for crate::api::RecoveryChallenge {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<String>>::sse_encode(self.words, serializer);
        <Vec<u32>>::sse_encode(self.positions, serializer);
    }
}

impl SseEncode for u32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u32::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for u64 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u64::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for u8 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u8(self).unwrap();
    }
}

impl SseEncode for () {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {}
}

impl SseEncode for usize {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer
            .cursor
            .write_u64::<NativeEndian>(self as _)
            .unwrap();
    }
}

impl SseEncode for crate::api::VaultFailure {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::VaultFailure::Credentials => 0,
                crate::api::VaultFailure::InvalidPassword => 1,
                crate::api::VaultFailure::InvalidPhrase => 2,
                crate::api::VaultFailure::Confirmation => 3,
                crate::api::VaultFailure::Exists => 4,
                crate::api::VaultFailure::Missing => 5,
                crate::api::VaultFailure::Locked => 6,
                crate::api::VaultFailure::Busy => 7,
                crate::api::VaultFailure::Unsupported => 8,
                crate::api::VaultFailure::Corrupt => 9,
                crate::api::VaultFailure::Storage => 10,
                crate::api::VaultFailure::Stale => 11,
                crate::api::VaultFailure::Closed => 12,
                crate::api::VaultFailure::Unavailable => 13,
                crate::api::VaultFailure::WriteUncertain => 14,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::VaultStatus {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::VaultStatus::Missing => 0,
                crate::api::VaultStatus::Locked => 1,
                crate::api::VaultStatus::Unlocked => 2,
                crate::api::VaultStatus::Confirmation => 3,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for bool {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_u8(self as _).unwrap();
    }
}

#[cfg(not(target_family = "wasm"))]
mod io {
    // This file is automatically generated, so please do not edit it.
    // @generated by `flutter_rust_bridge`@ 2.13.0.

    // Section: imports

    use super::*;
    use crate::api::*;
    use flutter_rust_bridge::for_generated::byteorder::{
        NativeEndian, ReadBytesExt, WriteBytesExt,
    };
    use flutter_rust_bridge::for_generated::{Lifetimeable, Lockable, transform_result_dco};
    use flutter_rust_bridge::{Handler, IntoIntoDart};

    // Section: boilerplate

    flutter_rust_bridge::frb_generated_boilerplate_io!();

    #[unsafe(no_mangle)]
    pub extern "C" fn frbgen_want_pass_core_rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
        ptr: *const std::ffi::c_void,
    ) {
        MoiArc::<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>>::increment_strong_count(ptr as _);
    }

    #[unsafe(no_mangle)]
    pub extern "C" fn frbgen_want_pass_core_rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
        ptr: *const std::ffi::c_void,
    ) {
        MoiArc::<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>>::decrement_strong_count(ptr as _);
    }
}
#[cfg(not(target_family = "wasm"))]
pub use io::*;
