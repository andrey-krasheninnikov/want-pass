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
pub(crate) const FLUTTER_RUST_BRIDGE_CODEGEN_CONTENT_HASH: i32 = 142378828;

// Section: executor

flutter_rust_bridge::frb_generated_default_handler!();

// Section: wire_funcs

fn wire__crate__api__Vault_account_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_account_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
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
                        crate::api::Vault::account_v1(&*api_that_guard, api_id, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_apply_account_import_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_apply_account_import_v1",
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
            let api_token = <String>::sse_decode(&mut deserializer);
            let api_selected = <Vec<u32>>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::apply_account_import_v1(
                        &*api_that_guard,
                        api_token,
                        api_selected,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_apply_backup_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_apply_backup_v1",
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
            let api_source = <String>::sse_decode(&mut deserializer);
            let api_phrase = <String>::sse_decode(&mut deserializer);
            let api_strategy =
                <crate::api::backup::BackupStrategyV1>::sse_decode(&mut deserializer);
            let api_choices =
                <Vec<crate::api::backup::BackupChoiceV1>>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
            let api_fingerprint = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::apply_backup_v1(
                        &*api_that_guard,
                        api_source,
                        api_phrase,
                        api_strategy,
                        api_choices,
                        api_revision,
                        api_fingerprint,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_authorize_operation_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_authorize_operation_v1",
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
            let api_action = <crate::api::policy::OperationV1>::sse_decode(&mut deserializer);
            let api_subject = <String>::sse_decode(&mut deserializer);
            let api_code = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::authorize_operation_v1(
                        &*api_that_guard,
                        api_action,
                        api_subject,
                        api_code,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_begin_external_totp_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_begin_external_totp_v1",
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
                    let output_ok = crate::api::Vault::begin_external_totp_v1(
                        &*api_that_guard,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_bindings_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_bindings_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::bindings_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_biometric_enabled_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_biometric_enabled_v1",
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
                        crate::api::Vault::biometric_enabled_v1(&*api_that_guard, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_cancel_account_import_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_cancel_account_import_v1",
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
            let api_token = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::cancel_account_import_v1(
                        &*api_that_guard,
                        api_token,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_card_list_rows_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_card_list_rows_v1",
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
            let api_ids = <Vec<String>>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::card_list_rows_v1(
                        &*api_that_guard,
                        api_ids,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_card_preview_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_card_preview_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::card_preview_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_card_rows_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_card_rows_v1",
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
            let api_ids = <Vec<String>>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::card_rows_v1(
                        &*api_that_guard,
                        api_ids,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_card_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_card_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
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
                        crate::api::Vault::card_v1(&*api_that_guard, api_id, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_clear_history_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_clear_history_v1",
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
            let api_card_id = <Option<String>>::sse_decode(&mut deserializer);
            let api_confirmed = <bool>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::clear_history_v1(
                        &*api_that_guard,
                        api_card_id,
                        api_confirmed,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
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
fn wire__crate__api__Vault_configure_biometric_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_configure_biometric_v1",
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
            let api_enable = <bool>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::configure_biometric_v1(
                        &*api_that_guard,
                        api_enable,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_configure_external_totp_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_configure_external_totp_v1",
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
            let api_code = <String>::sse_decode(&mut deserializer);
            let api_operations =
                <Vec<crate::api::policy::OperationV1>>::sse_decode(&mut deserializer);
            let api_disable = <bool>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::configure_external_totp_v1(
                        &*api_that_guard,
                        api_code,
                        api_operations,
                        api_disable,
                        api_generation,
                    )?;
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
fn wire__crate__api__Vault_confirm_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_confirm_v2",
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
            let api_password = <String>::sse_decode(&mut deserializer);
            let api_password_hint = <String>::sse_decode(&mut deserializer);
            let api_recovery_hint = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::confirm_v2(
                        &*api_that_guard,
                        api_answers,
                        api_password,
                        api_password_hint,
                        api_recovery_hint,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_confirm_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_confirm_v3",
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
            let api_password = <String>::sse_decode(&mut deserializer);
            let api_password_hint = <String>::sse_decode(&mut deserializer);
            let api_recovery_hint = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::confirm_v3(
                        &*api_that_guard,
                        api_answers,
                        api_password,
                        api_password_hint,
                        api_recovery_hint,
                        api_revision,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_content_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_content_v1",
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
                        crate::api::Vault::content_v1(&*api_that_guard, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_content_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_content_v2",
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
                        crate::api::Vault::content_v2(&*api_that_guard, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_copy_account_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_copy_account_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::copy_account_v1(
                        &*api_that_guard,
                        api_id,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_copy_card_field_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_copy_card_field_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_field = <crate::api::cards::FieldIdV1>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::copy_card_field_v1(
                        &*api_that_guard,
                        api_id,
                        api_field,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_copy_current_totp_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_copy_current_totp_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::copy_current_totp_v1(
                        &*api_that_guard,
                        api_id,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_copy_quick_card_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_copy_quick_card_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::copy_quick_card_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_current_totp_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_current_totp_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::current_totp_v1(
                        &*api_that_guard,
                        api_id,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_custom_card_values_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_custom_card_values_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::custom_card_values_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_custom_field_value_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_custom_field_value_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_field_id = <String>::sse_decode(&mut deserializer);
            let api_copy = <bool>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::custom_field_value_v1(
                        &*api_that_guard,
                        api_id,
                        api_field_id,
                        api_copy,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_delete_account_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_delete_account_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::delete_account_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_delete_card_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_delete_card_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::delete_card_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_delete_group_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_delete_group_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::delete_group_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_delete_group_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_delete_group_v2",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::delete_group_v2(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_enroll_external_totp_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_enroll_external_totp_v1",
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
            let api_code = <String>::sse_decode(&mut deserializer);
            let api_operations =
                <Vec<crate::api::policy::OperationV1>>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::enroll_external_totp_v1(
                        &*api_that_guard,
                        api_code,
                        api_operations,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_export_attachment_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_export_attachment_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_destination = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::export_attachment_v1(
                        &*api_that_guard,
                        api_id,
                        api_destination,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_export_backup_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_export_backup_v1",
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
            let api_destination = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::export_backup_v1(
                        &*api_that_guard,
                        api_destination,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_export_custom_file_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_export_custom_file_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_field_id = <String>::sse_decode(&mut deserializer);
            let api_destination = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::export_custom_file_v1(
                        &*api_that_guard,
                        api_id,
                        api_field_id,
                        api_destination,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_export_recovery_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_export_recovery_v2",
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
            let api_destination = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::export_recovery_v2(
                        &*api_that_guard,
                        api_destination,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_export_recovery_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_export_recovery_v3",
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
            let api_destination = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::export_recovery_v3(
                        &*api_that_guard,
                        api_destination,
                        api_revision,
                    )?;
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
fn wire__crate__api__Vault_hints_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_hints_v2",
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
                    let output_ok = crate::api::Vault::hints_v2(&*api_that_guard)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_historical_card_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_historical_card_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::historical_card_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_history_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_history_v1",
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
            let api_card_id = <Option<String>>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::history_v1(
                        &*api_that_guard,
                        api_card_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_local_tools_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_local_tools_v1",
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
            let api_command =
                <crate::api::local_tools::LocalToolCommandV1>::sse_decode(&mut deserializer);
            let api_body = <String>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::local_tools_v1(
                        &*api_that_guard,
                        api_command,
                        api_body,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
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
fn wire__crate__api__Vault_next_hotp_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_next_hotp_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::next_hotp_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
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
fn wire__crate__api__Vault_open_application_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_open_application_v1",
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
                    let output_ok = crate::api::Vault::open_application_v1(api_directory)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_prepare_account_import_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_prepare_account_import_v1",
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
            let api_source =
                <crate::api::account_import::AccountImportSourceV1>::sse_decode(&mut deserializer);
            let api_payloads = <Vec<String>>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::prepare_account_import_v1(
                        &*api_that_guard,
                        api_source,
                        api_payloads,
                        api_revision,
                        api_generation,
                    )?;
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
fn wire__crate__api__Vault_prepare_creation_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_prepare_creation_v2",
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
                    let output_ok = crate::api::Vault::prepare_creation_v2(
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
fn wire__crate__api__Vault_prepare_creation_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_prepare_creation_v3",
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
                    let output_ok = crate::api::Vault::prepare_creation_v3(
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
fn wire__crate__api__Vault_prepare_recovery_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_prepare_recovery_v2",
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
                    let output_ok = crate::api::Vault::prepare_recovery_v2(
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
fn wire__crate__api__Vault_prepare_recovery_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_prepare_recovery_v3",
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
                    let output_ok = crate::api::Vault::prepare_recovery_v3(
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
fn wire__crate__api__Vault_preview_backup_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_preview_backup_v1",
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
            let api_source = <String>::sse_decode(&mut deserializer);
            let api_phrase = <String>::sse_decode(&mut deserializer);
            let api_strategy =
                <crate::api::backup::BackupStrategyV1>::sse_decode(&mut deserializer);
            let api_choices =
                <Vec<crate::api::backup::BackupChoiceV1>>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::preview_backup_v1(
                        &*api_that_guard,
                        api_source,
                        api_phrase,
                        api_strategy,
                        api_choices,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_protection_settings_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_protection_settings_v1",
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
                    let output_ok = crate::api::Vault::protection_settings_v1(
                        &*api_that_guard,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_regenerate_recovery_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_regenerate_recovery_v3",
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
                    let output_ok = crate::api::Vault::regenerate_recovery_v3(
                        &*api_that_guard,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_remove_service_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_remove_service_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_replacement = <Option<String>>::sse_decode(&mut deserializer);
            let api_preserve = <bool>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::remove_service_v1(
                        &*api_that_guard,
                        api_id,
                        api_replacement,
                        api_preserve,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_reset_application_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_reset_application_v1",
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
                    let output_ok = crate::api::Vault::reset_application_v1(
                        &*api_that_guard,
                        api_phrase,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_restore_history_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_restore_history_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::restore_history_v1(
                        &*api_that_guard,
                        api_id,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_reveal_card_field_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_reveal_card_field_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_field = <crate::api::cards::FieldIdV1>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::reveal_card_field_v1(
                        &*api_that_guard,
                        api_id,
                        api_field,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_account_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_account_v1",
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
            let api_input = <crate::api::content::AccountInputV1>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_account_v1(
                        &*api_that_guard,
                        api_input,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_bindings_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_bindings_v1",
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
            let api_id = <String>::sse_decode(&mut deserializer);
            let api_bindings =
                <Vec<crate::api::catalog::ResourceBindingV1>>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_bindings_v1(
                        &*api_that_guard,
                        api_id,
                        api_bindings,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_card_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_card_v1",
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
            let api_input = <crate::api::cards::CardInputV1>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_card_v1(
                        &*api_that_guard,
                        api_input,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_custom_card_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_custom_card_v1",
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
            let api_input = <crate::api::catalog::CustomCardInputV1>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_custom_card_v1(
                        &*api_that_guard,
                        api_input,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_group_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_group_v1",
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
            let api_input = <crate::api::content::GroupInputV1>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_group_v1(
                        &*api_that_guard,
                        api_input,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_group_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_group_v2",
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
            let api_input = <crate::api::content::GroupInputV1>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_group_v2(
                        &*api_that_guard,
                        api_input,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_service_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_service_v1",
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
            let api_service =
                <crate::api::catalog::ServiceDefinitionV1>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_service_v1(
                        &*api_that_guard,
                        api_service,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_save_template_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_save_template_v1",
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
            let api_id = <Option<String>>::sse_decode(&mut deserializer);
            let api_name = <String>::sse_decode(&mut deserializer);
            let api_fields =
                <Vec<crate::api::catalog::TemplateFieldV1>>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::save_template_v1(
                        &*api_that_guard,
                        api_id,
                        api_name,
                        api_fields,
                        api_revision,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_search_cards_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_search_cards_v1",
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
            let api_query = <crate::api::cards::CardSearchV1>::sse_decode(&mut deserializer);
            let api_revision = <u64>::sse_decode(&mut deserializer);
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
                    let output_ok = crate::api::Vault::search_cards_v1(
                        &*api_that_guard,
                        api_query,
                        api_revision,
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
fn wire__crate__api__Vault_unlock_biometric_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_unlock_biometric_v1",
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
                        crate::api::Vault::unlock_biometric_v1(&*api_that_guard, api_generation)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_unlock_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_unlock_v3",
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
                    let output_ok = crate::api::Vault::unlock_v3(
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
fn wire__crate__api__Vault_validate_recovery_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_validate_recovery_v3",
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
                    let output_ok = crate::api::Vault::validate_recovery_v3(
                        &*api_that_guard,
                        api_phrase,
                        api_generation,
                    )?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__Vault_wait_for_exports_v2_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "Vault_wait_for_exports_v2",
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
                    let output_ok = crate::api::Vault::wait_for_exports_v2(&*api_that_guard)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__presets__card_presets_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "card_presets_v1",
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
            deserializer.end();
            move |context| {
                transform_result_sse::<_, ()>((move || {
                    let output_ok = Ok::<_, ()>(crate::api::presets::card_presets_v1())?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__phrase__inspect_recovery_input_v1_impl(
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) -> flutter_rust_bridge::for_generated::WireSyncRust2DartSse {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_sync::<flutter_rust_bridge::for_generated::SseCodec, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "inspect_recovery_input_v1",
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
            let api_input = <String>::sse_decode(&mut deserializer);
            deserializer.end();
            transform_result_sse::<_, ()>((move || {
                let output_ok =
                    Ok::<_, ()>(crate::api::phrase::inspect_recovery_input_v1(api_input))?;
                std::result::Result::Ok(output_ok)
            })())
        },
    )
}
fn wire__crate__api__local_tools__local_tool_subject_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "local_tool_subject_v1",
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
            let api_command =
                <crate::api::local_tools::LocalToolCommandV1>::sse_decode(&mut deserializer);
            let api_body = <String>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, crate::api::VaultFailure>((move || {
                    let output_ok =
                        crate::api::local_tools::local_tool_subject_v1(api_command, api_body)?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__v3__password_policy_v4_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "password_policy_v4",
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
            let api_password = <String>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, ()>((move || {
                    let output_ok = Ok::<_, ()>(crate::api::v3::password_policy_v4(api_password))?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__cards__services_v1_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "services_v1",
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
            deserializer.end();
            move |context| {
                transform_result_sse::<_, ()>((move || {
                    let output_ok = Ok::<_, ()>(crate::api::cards::services_v1())?;
                    std::result::Result::Ok(output_ok)
                })())
            }
        },
    )
}
fn wire__crate__api__v3__validate_password_v3_impl(
    port_: flutter_rust_bridge::for_generated::MessagePort,
    ptr_: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len_: i32,
    data_len_: i32,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap_normal::<flutter_rust_bridge::for_generated::SseCodec, _, _>(
        flutter_rust_bridge::for_generated::TaskInfo {
            debug_name: "validate_password_v3",
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
            let api_password = <String>::sse_decode(&mut deserializer);
            deserializer.end();
            move |context| {
                transform_result_sse::<_, ()>((move || {
                    let output_ok =
                        Ok::<_, ()>(crate::api::v3::validate_password_v3(api_password))?;
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

impl SseDecode for crate::api::account_import::AccountImportPreviewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_token = <String>::sse_decode(deserializer);
        let mut var_rows =
            <Vec<crate::api::account_import::AccountImportRowV1>>::sse_decode(deserializer);
        return crate::api::account_import::AccountImportPreviewV1 {
            token: var_token,
            rows: var_rows,
        };
    }
}

impl SseDecode for crate::api::account_import::AccountImportRowV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_duplicate = <bool>::sse_decode(deserializer);
        return crate::api::account_import::AccountImportRowV1 {
            name: var_name,
            duplicate: var_duplicate,
        };
    }
}

impl SseDecode for crate::api::account_import::AccountImportSourceV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::account_import::AccountImportSourceV1::ApplePasswords,
            1 => crate::api::account_import::AccountImportSourceV1::Authenticator,
            _ => unreachable!("Invalid variant for AccountImportSourceV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::content::AccountInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <Option<String>>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_login = <String>::sse_decode(deserializer);
        let mut var_password = <String>::sse_decode(deserializer);
        let mut var_groupIds = <Vec<String>>::sse_decode(deserializer);
        return crate::api::content::AccountInputV1 {
            id: var_id,
            name: var_name,
            description: var_description,
            login: var_login,
            password: var_password,
            group_ids: var_groupIds,
        };
    }
}

impl SseDecode for crate::api::content::AccountRecordV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_login = <String>::sse_decode(deserializer);
        let mut var_password = <String>::sse_decode(deserializer);
        let mut var_groupIds = <Vec<String>>::sse_decode(deserializer);
        return crate::api::content::AccountRecordV1 {
            id: var_id,
            name: var_name,
            description: var_description,
            login: var_login,
            password: var_password,
            group_ids: var_groupIds,
        };
    }
}

impl SseDecode for crate::api::content::AccountSummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_groupIds = <Vec<String>>::sse_decode(deserializer);
        return crate::api::content::AccountSummaryV1 {
            id: var_id,
            name: var_name,
            group_ids: var_groupIds,
        };
    }
}

impl SseDecode for crate::api::cards::AttachmentInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_bytes = <Vec<u8>>::sse_decode(deserializer);
        return crate::api::cards::AttachmentInputV1 {
            name: var_name,
            bytes: var_bytes,
        };
    }
}

impl SseDecode for crate::api::cards::AttachmentSummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_size = <u32>::sse_decode(deserializer);
        return crate::api::cards::AttachmentSummaryV1 {
            name: var_name,
            size: var_size,
        };
    }
}

impl SseDecode for crate::api::backup::BackupChoiceV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_entity = <crate::api::backup::BackupEntityV1>::sse_decode(deserializer);
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_resolution = <crate::api::backup::BackupResolutionV1>::sse_decode(deserializer);
        return crate::api::backup::BackupChoiceV1 {
            entity: var_entity,
            id: var_id,
            resolution: var_resolution,
        };
    }
}

impl SseDecode for crate::api::backup::BackupConflictV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_entity = <crate::api::backup::BackupEntityV1>::sse_decode(deserializer);
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_localName = <String>::sse_decode(deserializer);
        let mut var_incomingName = <String>::sse_decode(deserializer);
        let mut var_resolution =
            <Option<crate::api::backup::BackupResolutionV1>>::sse_decode(deserializer);
        return crate::api::backup::BackupConflictV1 {
            entity: var_entity,
            id: var_id,
            local_name: var_localName,
            incoming_name: var_incomingName,
            resolution: var_resolution,
        };
    }
}

impl SseDecode for crate::api::backup::BackupEntityV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::backup::BackupEntityV1::Group,
            1 => crate::api::backup::BackupEntityV1::Service,
            2 => crate::api::backup::BackupEntityV1::Template,
            3 => crate::api::backup::BackupEntityV1::Card,
            4 => crate::api::backup::BackupEntityV1::History,
            _ => unreachable!("Invalid variant for BackupEntityV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::backup::BackupPreviewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_revision = <u64>::sse_decode(deserializer);
        let mut var_fingerprint = <String>::sse_decode(deserializer);
        let mut var_added = <u32>::sse_decode(deserializer);
        let mut var_changed = <u32>::sse_decode(deserializer);
        let mut var_removed = <u32>::sse_decode(deserializer);
        let mut var_identicalCount = <u32>::sse_decode(deserializer);
        let mut var_conflicts =
            <Vec<crate::api::backup::BackupConflictV1>>::sse_decode(deserializer);
        return crate::api::backup::BackupPreviewV1 {
            revision: var_revision,
            fingerprint: var_fingerprint,
            added: var_added,
            changed: var_changed,
            removed: var_removed,
            identical_count: var_identicalCount,
            conflicts: var_conflicts,
        };
    }
}

impl SseDecode for crate::api::backup::BackupResolutionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::backup::BackupResolutionV1::Local,
            1 => crate::api::backup::BackupResolutionV1::Incoming,
            2 => crate::api::backup::BackupResolutionV1::Both,
            _ => unreachable!("Invalid variant for BackupResolutionV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::backup::BackupStrategyV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::backup::BackupStrategyV1::Replace,
            1 => crate::api::backup::BackupStrategyV1::Merge,
            _ => unreachable!("Invalid variant for BackupStrategyV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::catalog::BindingMethodV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::catalog::BindingMethodV1::Web,
            1 => crate::api::catalog::BindingMethodV1::Rest,
            2 => crate::api::catalog::BindingMethodV1::Ssh,
            3 => crate::api::catalog::BindingMethodV1::Git,
            4 => crate::api::catalog::BindingMethodV1::Registry,
            5 => crate::api::catalog::BindingMethodV1::Database,
            6 => crate::api::catalog::BindingMethodV1::Kubernetes,
            7 => crate::api::catalog::BindingMethodV1::AwsCli,
            8 => crate::api::catalog::BindingMethodV1::Netrc,
            9 => crate::api::catalog::BindingMethodV1::Mtls,
            _ => unreachable!("Invalid variant for BindingMethodV1: {}", inner),
        };
    }
}

impl SseDecode for bool {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_u8().unwrap() != 0
    }
}

impl SseDecode for crate::api::cards::CardInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <Option<String>>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_service = <String>::sse_decode(deserializer);
        let mut var_environment =
            <Option<crate::api::cards::EnvironmentV1>>::sse_decode(deserializer);
        let mut var_groupIds = <Vec<String>>::sse_decode(deserializer);
        let mut var_cardType = <crate::api::cards::CardTypeV1>::sse_decode(deserializer);
        let mut var_fields = <Vec<crate::api::cards::CardValueV1>>::sse_decode(deserializer);
        let mut var_attachment =
            <Option<crate::api::cards::AttachmentInputV1>>::sse_decode(deserializer);
        return crate::api::cards::CardInputV1 {
            id: var_id,
            name: var_name,
            description: var_description,
            service: var_service,
            environment: var_environment,
            group_ids: var_groupIds,
            card_type: var_cardType,
            fields: var_fields,
            attachment: var_attachment,
        };
    }
}

impl SseDecode for crate::api::cards::CardListRowV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_login = <Option<String>>::sse_decode(deserializer);
        return crate::api::cards::CardListRowV1 {
            id: var_id,
            login: var_login,
        };
    }
}

impl SseDecode for crate::api::cards::CardMatchesV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_revision = <u64>::sse_decode(deserializer);
        let mut var_cardIds = <Vec<String>>::sse_decode(deserializer);
        let mut var_groupIds = <Vec<String>>::sse_decode(deserializer);
        return crate::api::cards::CardMatchesV1 {
            revision: var_revision,
            card_ids: var_cardIds,
            group_ids: var_groupIds,
        };
    }
}

impl SseDecode for crate::api::presets::CardPresetV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_cardType = <crate::api::cards::CardTypeV1>::sse_decode(deserializer);
        let mut var_fields = <Vec<crate::api::presets::FieldSpecV1>>::sse_decode(deserializer);
        return crate::api::presets::CardPresetV1 {
            card_type: var_cardType,
            fields: var_fields,
        };
    }
}

impl SseDecode for crate::api::cards::CardPreviewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_row = <crate::api::cards::CardRowV1>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_protectedContainer = <bool>::sse_decode(deserializer);
        return crate::api::cards::CardPreviewV1 {
            row: var_row,
            description: var_description,
            protected_container: var_protectedContainer,
        };
    }
}

impl SseDecode for crate::api::cards::CardRecordV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_summary = <crate::api::cards::CardSummaryV1>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_fields = <Vec<crate::api::cards::CardValueV1>>::sse_decode(deserializer);
        let mut var_attachment =
            <Option<crate::api::cards::AttachmentSummaryV1>>::sse_decode(deserializer);
        let mut var_protectedContainer = <bool>::sse_decode(deserializer);
        return crate::api::cards::CardRecordV1 {
            summary: var_summary,
            description: var_description,
            fields: var_fields,
            attachment: var_attachment,
            protected_container: var_protectedContainer,
        };
    }
}

impl SseDecode for crate::api::cards::CardRowV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_fields = <Vec<crate::api::cards::FieldIdV1>>::sse_decode(deserializer);
        let mut var_login = <Option<String>>::sse_decode(deserializer);
        let mut var_otp = <Option<crate::api::otp::TotpCodeV1>>::sse_decode(deserializer);
        let mut var_attachment =
            <Option<crate::api::cards::AttachmentSummaryV1>>::sse_decode(deserializer);
        return crate::api::cards::CardRowV1 {
            id: var_id,
            fields: var_fields,
            login: var_login,
            otp: var_otp,
            attachment: var_attachment,
        };
    }
}

impl SseDecode for crate::api::cards::CardSearchV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_text = <String>::sse_decode(deserializer);
        let mut var_cardType = <Option<crate::api::cards::CardTypeV1>>::sse_decode(deserializer);
        let mut var_service = <Option<String>>::sse_decode(deserializer);
        let mut var_environment =
            <Option<crate::api::cards::EnvironmentV1>>::sse_decode(deserializer);
        let mut var_withoutEnvironment = <bool>::sse_decode(deserializer);
        return crate::api::cards::CardSearchV1 {
            text: var_text,
            card_type: var_cardType,
            service: var_service,
            environment: var_environment,
            without_environment: var_withoutEnvironment,
        };
    }
}

impl SseDecode for crate::api::cards::CardSummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_service = <String>::sse_decode(deserializer);
        let mut var_environment =
            <Option<crate::api::cards::EnvironmentV1>>::sse_decode(deserializer);
        let mut var_groupIds = <Vec<String>>::sse_decode(deserializer);
        let mut var_cardType = <crate::api::cards::CardTypeV1>::sse_decode(deserializer);
        let mut var_templateVersion = <u32>::sse_decode(deserializer);
        let mut var_customTemplateId = <Option<String>>::sse_decode(deserializer);
        return crate::api::cards::CardSummaryV1 {
            id: var_id,
            name: var_name,
            service: var_service,
            environment: var_environment,
            group_ids: var_groupIds,
            card_type: var_cardType,
            template_version: var_templateVersion,
            custom_template_id: var_customTemplateId,
        };
    }
}

impl SseDecode for crate::api::cards::CardTypeV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::cards::CardTypeV1::Account,
            1 => crate::api::cards::CardTypeV1::Pat,
            2 => crate::api::cards::CardTypeV1::Rsa,
            3 => crate::api::cards::CardTypeV1::Ed25519,
            4 => crate::api::cards::CardTypeV1::SecretKey,
            5 => crate::api::cards::CardTypeV1::Passphrase,
            6 => crate::api::cards::CardTypeV1::RecoveryCodes,
            7 => crate::api::cards::CardTypeV1::RecoveryUrl,
            8 => crate::api::cards::CardTypeV1::SecretQa,
            9 => crate::api::cards::CardTypeV1::Vless,
            10 => crate::api::cards::CardTypeV1::WireGuard,
            11 => crate::api::cards::CardTypeV1::Gpg,
            12 => crate::api::cards::CardTypeV1::Certificate,
            13 => crate::api::cards::CardTypeV1::OAuth,
            14 => crate::api::cards::CardTypeV1::Dsn,
            15 => crate::api::cards::CardTypeV1::Kubeconfig,
            16 => crate::api::cards::CardTypeV1::WebhookSecret,
            17 => crate::api::cards::CardTypeV1::SecureNote,
            18 => crate::api::cards::CardTypeV1::File,
            19 => crate::api::cards::CardTypeV1::ApiKey,
            20 => crate::api::cards::CardTypeV1::Totp,
            21 => crate::api::cards::CardTypeV1::AwsIam,
            22 => crate::api::cards::CardTypeV1::GoogleCloudKey,
            23 => crate::api::cards::CardTypeV1::AzureAppSecret,
            24 => crate::api::cards::CardTypeV1::BearerToken,
            25 => crate::api::cards::CardTypeV1::AppPassword,
            26 => crate::api::cards::CardTypeV1::SshCertificate,
            27 => crate::api::cards::CardTypeV1::KubernetesToken,
            28 => crate::api::cards::CardTypeV1::OpenVpn,
            29 => crate::api::cards::CardTypeV1::Ipsec,
            30 => crate::api::cards::CardTypeV1::KeyContainer,
            31 => crate::api::cards::CardTypeV1::ArtifactSigningKey,
            32 => crate::api::cards::CardTypeV1::ApnsKey,
            33 => crate::api::cards::CardTypeV1::AppStoreConnectKey,
            34 => crate::api::cards::CardTypeV1::RegistryAccess,
            35 => crate::api::cards::CardTypeV1::EnvironmentVariables,
            36 => crate::api::cards::CardTypeV1::SmtpAccess,
            37 => crate::api::cards::CardTypeV1::PresignedUrl,
            38 => crate::api::cards::CardTypeV1::SessionCookie,
            39 => crate::api::cards::CardTypeV1::Hotp,
            40 => crate::api::cards::CardTypeV1::LicenseKey,
            41 => crate::api::cards::CardTypeV1::Wifi,
            42 => crate::api::cards::CardTypeV1::DevicePin,
            43 => crate::api::cards::CardTypeV1::SimPinPuk,
            44 => crate::api::cards::CardTypeV1::PaymentCard,
            45 => crate::api::cards::CardTypeV1::BankDetails,
            46 => crate::api::cards::CardTypeV1::IdentityDocument,
            47 => crate::api::cards::CardTypeV1::WalletMnemonic,
            48 => crate::api::cards::CardTypeV1::WalletPrivateKey,
            49 => crate::api::cards::CardTypeV1::Custom,
            _ => unreachable!("Invalid variant for CardTypeV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::cards::CardValueV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <crate::api::cards::FieldIdV1>::sse_decode(deserializer);
        let mut var_value = <String>::sse_decode(deserializer);
        return crate::api::cards::CardValueV1 {
            id: var_id,
            value: var_value,
        };
    }
}

impl SseDecode for crate::api::content::ContentSnapshotV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_revision = <u64>::sse_decode(deserializer);
        let mut var_groups = <Vec<crate::api::content::GroupRecordV1>>::sse_decode(deserializer);
        let mut var_accounts =
            <Vec<crate::api::content::AccountSummaryV1>>::sse_decode(deserializer);
        return crate::api::content::ContentSnapshotV1 {
            revision: var_revision,
            groups: var_groups,
            accounts: var_accounts,
        };
    }
}

impl SseDecode for crate::api::cards::ContentSnapshotV2 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_revision = <u64>::sse_decode(deserializer);
        let mut var_groups = <Vec<crate::api::content::GroupRecordV1>>::sse_decode(deserializer);
        let mut var_cards = <Vec<crate::api::cards::CardSummaryV1>>::sse_decode(deserializer);
        let mut var_services =
            <Vec<crate::api::catalog::ServiceDefinitionV1>>::sse_decode(deserializer);
        let mut var_templates =
            <Vec<crate::api::catalog::TemplateDefinitionV1>>::sse_decode(deserializer);
        return crate::api::cards::ContentSnapshotV2 {
            revision: var_revision,
            groups: var_groups,
            cards: var_cards,
            services: var_services,
            templates: var_templates,
        };
    }
}

impl SseDecode for crate::api::catalog::CustomCardInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <Option<String>>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_service = <String>::sse_decode(deserializer);
        let mut var_environment =
            <Option<crate::api::cards::EnvironmentV1>>::sse_decode(deserializer);
        let mut var_groupIds = <Vec<String>>::sse_decode(deserializer);
        let mut var_templateId = <String>::sse_decode(deserializer);
        let mut var_templateVersion = <u32>::sse_decode(deserializer);
        let mut var_acceptTemplateUpdate = <bool>::sse_decode(deserializer);
        let mut var_values =
            <Vec<crate::api::catalog::CustomValueInputV1>>::sse_decode(deserializer);
        return crate::api::catalog::CustomCardInputV1 {
            id: var_id,
            name: var_name,
            description: var_description,
            service: var_service,
            environment: var_environment,
            group_ids: var_groupIds,
            template_id: var_templateId,
            template_version: var_templateVersion,
            accept_template_update: var_acceptTemplateUpdate,
            values: var_values,
        };
    }
}

impl SseDecode for crate::api::catalog::CustomFieldKindV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::catalog::CustomFieldKindV1::Text,
            1 => crate::api::catalog::CustomFieldKindV1::Concealed,
            2 => crate::api::catalog::CustomFieldKindV1::Url,
            3 => crate::api::catalog::CustomFieldKindV1::Otp,
            4 => crate::api::catalog::CustomFieldKindV1::Codes,
            5 => crate::api::catalog::CustomFieldKindV1::File,
            _ => unreachable!("Invalid variant for CustomFieldKindV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::catalog::CustomValueInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_fieldId = <String>::sse_decode(deserializer);
        let mut var_value = <String>::sse_decode(deserializer);
        let mut var_file = <Option<crate::api::cards::AttachmentInputV1>>::sse_decode(deserializer);
        let mut var_keepFile = <bool>::sse_decode(deserializer);
        return crate::api::catalog::CustomValueInputV1 {
            field_id: var_fieldId,
            value: var_value,
            file: var_file,
            keep_file: var_keepFile,
        };
    }
}

impl SseDecode for crate::api::catalog::CustomValueViewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_fieldId = <String>::sse_decode(deserializer);
        let mut var_value = <String>::sse_decode(deserializer);
        let mut var_file =
            <Option<crate::api::cards::AttachmentSummaryV1>>::sse_decode(deserializer);
        return crate::api::catalog::CustomValueViewV1 {
            field_id: var_fieldId,
            value: var_value,
            file: var_file,
        };
    }
}

impl SseDecode for crate::api::cards::EnvironmentV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::cards::EnvironmentV1::Local,
            1 => crate::api::cards::EnvironmentV1::UnitTests,
            2 => crate::api::cards::EnvironmentV1::IntegrationTests,
            3 => crate::api::cards::EnvironmentV1::E2eTests,
            4 => crate::api::cards::EnvironmentV1::Development,
            5 => crate::api::cards::EnvironmentV1::Stand,
            6 => crate::api::cards::EnvironmentV1::Feature,
            7 => crate::api::cards::EnvironmentV1::Stage,
            8 => crate::api::cards::EnvironmentV1::PreRelease,
            9 => crate::api::cards::EnvironmentV1::Production,
            _ => unreachable!("Invalid variant for EnvironmentV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::cards::FieldIdV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::cards::FieldIdV1::Login,
            1 => crate::api::cards::FieldIdV1::Password,
            2 => crate::api::cards::FieldIdV1::TotpSeed,
            3 => crate::api::cards::FieldIdV1::TotpAlgorithm,
            4 => crate::api::cards::FieldIdV1::TotpDigits,
            5 => crate::api::cards::FieldIdV1::TotpPeriod,
            6 => crate::api::cards::FieldIdV1::RecoveryCodes,
            7 => crate::api::cards::FieldIdV1::ReserveLogins,
            8 => crate::api::cards::FieldIdV1::Value,
            9 => crate::api::cards::FieldIdV1::PublicKey,
            10 => crate::api::cards::FieldIdV1::PrivateKey,
            11 => crate::api::cards::FieldIdV1::Certificate,
            12 => crate::api::cards::FieldIdV1::ClientId,
            13 => crate::api::cards::FieldIdV1::ClientSecret,
            14 => crate::api::cards::FieldIdV1::AccessToken,
            15 => crate::api::cards::FieldIdV1::RefreshToken,
            16 => crate::api::cards::FieldIdV1::Question,
            17 => crate::api::cards::FieldIdV1::Answer,
            18 => crate::api::cards::FieldIdV1::KeyId,
            19 => crate::api::cards::FieldIdV1::AccessKeyId,
            20 => crate::api::cards::FieldIdV1::SessionToken,
            21 => crate::api::cards::FieldIdV1::JsonKey,
            22 => crate::api::cards::FieldIdV1::Project,
            23 => crate::api::cards::FieldIdV1::TenantId,
            24 => crate::api::cards::FieldIdV1::ExpiresAt,
            25 => crate::api::cards::FieldIdV1::Namespace,
            26 => crate::api::cards::FieldIdV1::AccountName,
            27 => crate::api::cards::FieldIdV1::Configuration,
            28 => crate::api::cards::FieldIdV1::Identity,
            29 => crate::api::cards::FieldIdV1::ContainerFormat,
            30 => crate::api::cards::FieldIdV1::TeamId,
            31 => crate::api::cards::FieldIdV1::IssuerId,
            32 => crate::api::cards::FieldIdV1::Endpoint,
            33 => crate::api::cards::FieldIdV1::Variables,
            34 => crate::api::cards::FieldIdV1::Url,
            35 => crate::api::cards::FieldIdV1::Domain,
            36 => crate::api::cards::FieldIdV1::CookieName,
            37 => crate::api::cards::FieldIdV1::HotpSeed,
            38 => crate::api::cards::FieldIdV1::Counter,
            39 => crate::api::cards::FieldIdV1::Product,
            40 => crate::api::cards::FieldIdV1::Ssid,
            41 => crate::api::cards::FieldIdV1::Device,
            42 => crate::api::cards::FieldIdV1::Pin,
            43 => crate::api::cards::FieldIdV1::Carrier,
            44 => crate::api::cards::FieldIdV1::Puk,
            45 => crate::api::cards::FieldIdV1::CardNumber,
            46 => crate::api::cards::FieldIdV1::Holder,
            47 => crate::api::cards::FieldIdV1::ExpiryMonth,
            48 => crate::api::cards::FieldIdV1::Iban,
            49 => crate::api::cards::FieldIdV1::AccountNumber,
            50 => crate::api::cards::FieldIdV1::Bic,
            51 => crate::api::cards::FieldIdV1::DocumentType,
            52 => crate::api::cards::FieldIdV1::DocumentNumber,
            53 => crate::api::cards::FieldIdV1::Authority,
            54 => crate::api::cards::FieldIdV1::Mnemonic,
            55 => crate::api::cards::FieldIdV1::WalletPassphrase,
            56 => crate::api::cards::FieldIdV1::Network,
            57 => crate::api::cards::FieldIdV1::Address,
            58 => crate::api::cards::FieldIdV1::Scopes,
            _ => unreachable!("Invalid variant for FieldIdV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::presets::FieldSpecV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <crate::api::cards::FieldIdV1>::sse_decode(deserializer);
        let mut var_required_ = <bool>::sse_decode(deserializer);
        let mut var_concealed = <bool>::sse_decode(deserializer);
        let mut var_multiline = <bool>::sse_decode(deserializer);
        let mut var_maxBytes = <u32>::sse_decode(deserializer);
        return crate::api::presets::FieldSpecV1 {
            id: var_id,
            required: var_required_,
            concealed: var_concealed,
            multiline: var_multiline,
            max_bytes: var_maxBytes,
        };
    }
}

impl SseDecode for crate::api::content::GroupInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <Option<String>>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_icon = <String>::sse_decode(deserializer);
        let mut var_logo = <Vec<u8>>::sse_decode(deserializer);
        return crate::api::content::GroupInputV1 {
            id: var_id,
            name: var_name,
            description: var_description,
            icon: var_icon,
            logo: var_logo,
        };
    }
}

impl SseDecode for crate::api::content::GroupRecordV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_icon = <String>::sse_decode(deserializer);
        let mut var_logo = <Vec<u8>>::sse_decode(deserializer);
        return crate::api::content::GroupRecordV1 {
            id: var_id,
            name: var_name,
            description: var_description,
            icon: var_icon,
            logo: var_logo,
        };
    }
}

impl SseDecode for crate::api::catalog::HistoricalCardV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_summary = <crate::api::cards::CardSummaryV1>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_fields = <Vec<crate::api::cards::CardValueV1>>::sse_decode(deserializer);
        let mut var_customValues =
            <Vec<crate::api::catalog::CustomValueViewV1>>::sse_decode(deserializer);
        let mut var_bindings =
            <Vec<crate::api::catalog::ResourceBindingV1>>::sse_decode(deserializer);
        let mut var_attachment =
            <Option<crate::api::cards::AttachmentSummaryV1>>::sse_decode(deserializer);
        return crate::api::catalog::HistoricalCardV1 {
            summary: var_summary,
            description: var_description,
            fields: var_fields,
            custom_values: var_customValues,
            bindings: var_bindings,
            attachment: var_attachment,
        };
    }
}

impl SseDecode for crate::api::catalog::HistorySummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_at = <i64>::sse_decode(deserializer);
        let mut var_cardId = <String>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_service = <String>::sse_decode(deserializer);
        return crate::api::catalog::HistorySummaryV1 {
            id: var_id,
            at: var_at,
            card_id: var_cardId,
            name: var_name,
            service: var_service,
        };
    }
}

impl SseDecode for crate::api::cards::HotpAdvanceV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_snapshot = <crate::api::cards::ContentSnapshotV2>::sse_decode(deserializer);
        let mut var_code = <String>::sse_decode(deserializer);
        return crate::api::cards::HotpAdvanceV1 {
            snapshot: var_snapshot,
            code: var_code,
        };
    }
}

impl SseDecode for i32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_i32::<NativeEndian>().unwrap()
    }
}

impl SseDecode for i64 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        deserializer.cursor.read_i64::<NativeEndian>().unwrap()
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

impl SseDecode for Vec<crate::api::account_import::AccountImportRowV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::account_import::AccountImportRowV1>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::content::AccountSummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::content::AccountSummaryV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::backup::BackupChoiceV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::backup::BackupChoiceV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::backup::BackupConflictV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::backup::BackupConflictV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::cards::CardListRowV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::cards::CardListRowV1>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::presets::CardPresetV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::presets::CardPresetV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::cards::CardRowV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::cards::CardRowV1>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::cards::CardSummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::cards::CardSummaryV1>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::cards::CardValueV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::cards::CardValueV1>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::catalog::CustomValueInputV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::CustomValueInputV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::catalog::CustomValueViewV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::CustomValueViewV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::cards::FieldIdV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::cards::FieldIdV1>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::presets::FieldSpecV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::presets::FieldSpecV1>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::content::GroupRecordV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::content::GroupRecordV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::catalog::HistorySummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::HistorySummaryV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<Vec<String>> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<Vec<String>>::sse_decode(deserializer));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::policy::OperationV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::policy::OperationV1>::sse_decode(deserializer));
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

impl SseDecode for Vec<crate::api::catalog::ResourceBindingV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::ResourceBindingV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::catalog::ServiceDefinitionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::ServiceDefinitionV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::catalog::TemplateDefinitionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::TemplateDefinitionV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::catalog::TemplateFieldV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::TemplateFieldV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for Vec<crate::api::catalog::TemplateVersionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut len_ = <i32>::sse_decode(deserializer);
        let mut ans_ = Vec::with_capacity(len_ as usize);
        for idx_ in 0..len_ {
            ans_.push(<crate::api::catalog::TemplateVersionV1>::sse_decode(
                deserializer,
            ));
        }
        return ans_;
    }
}

impl SseDecode for crate::api::local_tools::LocalToolCommandV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::local_tools::LocalToolCommandV1::Dashboard,
            1 => crate::api::local_tools::LocalToolCommandV1::Configure,
            2 => crate::api::local_tools::LocalToolCommandV1::Disconnect,
            3 => crate::api::local_tools::LocalToolCommandV1::Grant,
            4 => crate::api::local_tools::LocalToolCommandV1::Revoke,
            5 => crate::api::local_tools::LocalToolCommandV1::Request,
            6 => crate::api::local_tools::LocalToolCommandV1::PublicKey,
            7 => crate::api::local_tools::LocalToolCommandV1::AgentIdentity,
            8 => crate::api::local_tools::LocalToolCommandV1::AgentSign,
            _ => unreachable!("Invalid variant for LocalToolCommandV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::policy::OperationV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::policy::OperationV1::Reveal,
            1 => crate::api::policy::OperationV1::Copy,
            2 => crate::api::policy::OperationV1::Export,
            3 => crate::api::policy::OperationV1::Transfer,
            4 => crate::api::policy::OperationV1::IntegrationGrant,
            5 => crate::api::policy::OperationV1::RecoveryKit,
            6 => crate::api::policy::OperationV1::Delete,
            7 => crate::api::policy::OperationV1::Protection,
            _ => unreachable!("Invalid variant for OperationV1: {}", inner),
        };
    }
}

impl SseDecode for Option<String> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<String>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::cards::AttachmentInputV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::cards::AttachmentInputV1>::sse_decode(
                deserializer,
            ));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::cards::AttachmentSummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::cards::AttachmentSummaryV1>::sse_decode(
                deserializer,
            ));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::backup::BackupResolutionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::backup::BackupResolutionV1>::sse_decode(
                deserializer,
            ));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::cards::CardTypeV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::cards::CardTypeV1>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::cards::EnvironmentV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::cards::EnvironmentV1>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for Option<crate::api::otp::TotpCodeV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        if (<bool>::sse_decode(deserializer)) {
            return Some(<crate::api::otp::TotpCodeV1>::sse_decode(deserializer));
        } else {
            return None;
        }
    }
}

impl SseDecode for crate::api::v3::PasswordPolicyStatusV4 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_minimumLength = <bool>::sse_decode(deserializer);
        let mut var_maximumBytes = <bool>::sse_decode(deserializer);
        let mut var_uppercase = <bool>::sse_decode(deserializer);
        let mut var_lowercase = <bool>::sse_decode(deserializer);
        let mut var_digit = <bool>::sse_decode(deserializer);
        let mut var_special = <bool>::sse_decode(deserializer);
        let mut var_singleLine = <bool>::sse_decode(deserializer);
        return crate::api::v3::PasswordPolicyStatusV4 {
            minimum_length: var_minimumLength,
            maximum_bytes: var_maximumBytes,
            uppercase: var_uppercase,
            lowercase: var_lowercase,
            digit: var_digit,
            special: var_special,
            single_line: var_singleLine,
        };
    }
}

impl SseDecode for crate::api::policy::ProtectionSettingsV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_enrolled = <bool>::sse_decode(deserializer);
        let mut var_operations = <Vec<crate::api::policy::OperationV1>>::sse_decode(deserializer);
        return crate::api::policy::ProtectionSettingsV1 {
            enrolled: var_enrolled,
            operations: var_operations,
        };
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

impl SseDecode for crate::api::v2::RecoveryChallengeV2 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_words = <Vec<String>>::sse_decode(deserializer);
        let mut var_positions = <Vec<u32>>::sse_decode(deserializer);
        let mut var_choices = <Vec<Vec<String>>>::sse_decode(deserializer);
        return crate::api::v2::RecoveryChallengeV2 {
            words: var_words,
            positions: var_positions,
            choices: var_choices,
        };
    }
}

impl SseDecode for crate::api::v3::RecoveryChallengeV3 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_words = <Vec<String>>::sse_decode(deserializer);
        let mut var_positions = <Vec<u32>>::sse_decode(deserializer);
        let mut var_choices = <Vec<Vec<String>>>::sse_decode(deserializer);
        let mut var_json = <String>::sse_decode(deserializer);
        let mut var_revision = <u64>::sse_decode(deserializer);
        return crate::api::v3::RecoveryChallengeV3 {
            words: var_words,
            positions: var_positions,
            choices: var_choices,
            json: var_json,
            revision: var_revision,
        };
    }
}

impl SseDecode for crate::api::phrase::RecoveryInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_words = <Vec<String>>::sse_decode(deserializer);
        let mut var_invalidPositions = <Vec<u32>>::sse_decode(deserializer);
        let mut var_complete = <bool>::sse_decode(deserializer);
        let mut var_recognized = <bool>::sse_decode(deserializer);
        return crate::api::phrase::RecoveryInputV1 {
            words: var_words,
            invalid_positions: var_invalidPositions,
            complete: var_complete,
            recognized: var_recognized,
        };
    }
}

impl SseDecode for crate::api::catalog::ResourceBindingV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_kind = <crate::api::catalog::ResourceKindV1>::sse_decode(deserializer);
        let mut var_target = <String>::sse_decode(deserializer);
        let mut var_method = <crate::api::catalog::BindingMethodV1>::sse_decode(deserializer);
        let mut var_fields = <Vec<String>>::sse_decode(deserializer);
        return crate::api::catalog::ResourceBindingV1 {
            id: var_id,
            kind: var_kind,
            target: var_target,
            method: var_method,
            fields: var_fields,
        };
    }
}

impl SseDecode for crate::api::catalog::ResourceKindV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut inner = <i32>::sse_decode(deserializer);
        return match inner {
            0 => crate::api::catalog::ResourceKindV1::WebApp,
            1 => crate::api::catalog::ResourceKindV1::RestEndpoint,
            2 => crate::api::catalog::ResourceKindV1::SshHost,
            3 => crate::api::catalog::ResourceKindV1::GitRepository,
            4 => crate::api::catalog::ResourceKindV1::PackageRegistry,
            5 => crate::api::catalog::ResourceKindV1::ContainerRegistry,
            6 => crate::api::catalog::ResourceKindV1::Database,
            7 => crate::api::catalog::ResourceKindV1::KubernetesContext,
            _ => unreachable!("Invalid variant for ResourceKindV1: {}", inner),
        };
    }
}

impl SseDecode for crate::api::catalog::ServiceDefinitionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_description = <String>::sse_decode(deserializer);
        let mut var_icon = <String>::sse_decode(deserializer);
        let mut var_logo = <Vec<u8>>::sse_decode(deserializer);
        let mut var_archived = <bool>::sse_decode(deserializer);
        return crate::api::catalog::ServiceDefinitionV1 {
            id: var_id,
            name: var_name,
            description: var_description,
            icon: var_icon,
            logo: var_logo,
            archived: var_archived,
        };
    }
}

impl SseDecode for crate::api::catalog::TemplateDefinitionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_versions =
            <Vec<crate::api::catalog::TemplateVersionV1>>::sse_decode(deserializer);
        return crate::api::catalog::TemplateDefinitionV1 {
            id: var_id,
            versions: var_versions,
        };
    }
}

impl SseDecode for crate::api::catalog::TemplateFieldV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_id = <String>::sse_decode(deserializer);
        let mut var_label = <String>::sse_decode(deserializer);
        let mut var_kind = <crate::api::catalog::CustomFieldKindV1>::sse_decode(deserializer);
        let mut var_required_ = <bool>::sse_decode(deserializer);
        return crate::api::catalog::TemplateFieldV1 {
            id: var_id,
            label: var_label,
            kind: var_kind,
            required: var_required_,
        };
    }
}

impl SseDecode for crate::api::catalog::TemplateVersionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_number = <u32>::sse_decode(deserializer);
        let mut var_name = <String>::sse_decode(deserializer);
        let mut var_fields = <Vec<crate::api::catalog::TemplateFieldV1>>::sse_decode(deserializer);
        return crate::api::catalog::TemplateVersionV1 {
            number: var_number,
            name: var_name,
            fields: var_fields,
        };
    }
}

impl SseDecode for crate::api::otp::TotpCodeV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_code = <String>::sse_decode(deserializer);
        let mut var_validUntil = <u64>::sse_decode(deserializer);
        let mut var_period = <u64>::sse_decode(deserializer);
        return crate::api::otp::TotpCodeV1 {
            code: var_code,
            valid_until: var_validUntil,
            period: var_period,
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

impl SseDecode for crate::api::v2::VaultHintsV2 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_decode(deserializer: &mut flutter_rust_bridge::for_generated::SseDeserializer) -> Self {
        let mut var_password = <String>::sse_decode(deserializer);
        let mut var_recovery = <String>::sse_decode(deserializer);
        return crate::api::v2::VaultHintsV2 {
            password: var_password,
            recovery: var_recovery,
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

fn pde_ffi_dispatcher_primary_impl(
    func_id: i32,
    port: flutter_rust_bridge::for_generated::MessagePort,
    ptr: flutter_rust_bridge::for_generated::PlatformGeneralizedUint8ListPtr,
    rust_vec_len: i32,
    data_len: i32,
) {
    // Codec=Pde (Serialization + dispatch), see doc to use other codecs
    match func_id {
        1 => wire__crate__api__Vault_account_v1_impl(port, ptr, rust_vec_len, data_len),
        2 => {
            wire__crate__api__Vault_apply_account_import_v1_impl(port, ptr, rust_vec_len, data_len)
        }
        3 => wire__crate__api__Vault_apply_backup_v1_impl(port, ptr, rust_vec_len, data_len),
        4 => wire__crate__api__Vault_authorize_operation_v1_impl(port, ptr, rust_vec_len, data_len),
        5 => wire__crate__api__Vault_begin_external_totp_v1_impl(port, ptr, rust_vec_len, data_len),
        6 => wire__crate__api__Vault_bindings_v1_impl(port, ptr, rust_vec_len, data_len),
        7 => wire__crate__api__Vault_biometric_enabled_v1_impl(port, ptr, rust_vec_len, data_len),
        8 => {
            wire__crate__api__Vault_cancel_account_import_v1_impl(port, ptr, rust_vec_len, data_len)
        }
        9 => wire__crate__api__Vault_card_list_rows_v1_impl(port, ptr, rust_vec_len, data_len),
        10 => wire__crate__api__Vault_card_preview_v1_impl(port, ptr, rust_vec_len, data_len),
        11 => wire__crate__api__Vault_card_rows_v1_impl(port, ptr, rust_vec_len, data_len),
        12 => wire__crate__api__Vault_card_v1_impl(port, ptr, rust_vec_len, data_len),
        13 => wire__crate__api__Vault_clear_history_v1_impl(port, ptr, rust_vec_len, data_len),
        14 => wire__crate__api__Vault_close_impl(port, ptr, rust_vec_len, data_len),
        15 => {
            wire__crate__api__Vault_configure_biometric_v1_impl(port, ptr, rust_vec_len, data_len)
        }
        16 => wire__crate__api__Vault_configure_external_totp_v1_impl(
            port,
            ptr,
            rust_vec_len,
            data_len,
        ),
        17 => wire__crate__api__Vault_confirm_impl(port, ptr, rust_vec_len, data_len),
        18 => wire__crate__api__Vault_confirm_v2_impl(port, ptr, rust_vec_len, data_len),
        19 => wire__crate__api__Vault_confirm_v3_impl(port, ptr, rust_vec_len, data_len),
        20 => wire__crate__api__Vault_content_v1_impl(port, ptr, rust_vec_len, data_len),
        21 => wire__crate__api__Vault_content_v2_impl(port, ptr, rust_vec_len, data_len),
        22 => wire__crate__api__Vault_copy_account_v1_impl(port, ptr, rust_vec_len, data_len),
        23 => wire__crate__api__Vault_copy_card_field_v1_impl(port, ptr, rust_vec_len, data_len),
        24 => wire__crate__api__Vault_copy_current_totp_v1_impl(port, ptr, rust_vec_len, data_len),
        25 => wire__crate__api__Vault_copy_quick_card_v1_impl(port, ptr, rust_vec_len, data_len),
        26 => wire__crate__api__Vault_current_totp_v1_impl(port, ptr, rust_vec_len, data_len),
        27 => wire__crate__api__Vault_custom_card_values_v1_impl(port, ptr, rust_vec_len, data_len),
        28 => wire__crate__api__Vault_custom_field_value_v1_impl(port, ptr, rust_vec_len, data_len),
        29 => wire__crate__api__Vault_delete_account_v1_impl(port, ptr, rust_vec_len, data_len),
        30 => wire__crate__api__Vault_delete_card_v1_impl(port, ptr, rust_vec_len, data_len),
        31 => wire__crate__api__Vault_delete_group_v1_impl(port, ptr, rust_vec_len, data_len),
        32 => wire__crate__api__Vault_delete_group_v2_impl(port, ptr, rust_vec_len, data_len),
        33 => {
            wire__crate__api__Vault_enroll_external_totp_v1_impl(port, ptr, rust_vec_len, data_len)
        }
        34 => wire__crate__api__Vault_export_attachment_v1_impl(port, ptr, rust_vec_len, data_len),
        35 => wire__crate__api__Vault_export_backup_v1_impl(port, ptr, rust_vec_len, data_len),
        36 => wire__crate__api__Vault_export_custom_file_v1_impl(port, ptr, rust_vec_len, data_len),
        37 => wire__crate__api__Vault_export_recovery_v2_impl(port, ptr, rust_vec_len, data_len),
        38 => wire__crate__api__Vault_export_recovery_v3_impl(port, ptr, rust_vec_len, data_len),
        40 => wire__crate__api__Vault_hints_v2_impl(port, ptr, rust_vec_len, data_len),
        41 => wire__crate__api__Vault_historical_card_v1_impl(port, ptr, rust_vec_len, data_len),
        42 => wire__crate__api__Vault_history_v1_impl(port, ptr, rust_vec_len, data_len),
        43 => wire__crate__api__Vault_local_tools_v1_impl(port, ptr, rust_vec_len, data_len),
        45 => wire__crate__api__Vault_next_hotp_v1_impl(port, ptr, rust_vec_len, data_len),
        46 => wire__crate__api__Vault_open_impl(port, ptr, rust_vec_len, data_len),
        47 => wire__crate__api__Vault_open_application_v1_impl(port, ptr, rust_vec_len, data_len),
        48 => wire__crate__api__Vault_prepare_account_import_v1_impl(
            port,
            ptr,
            rust_vec_len,
            data_len,
        ),
        49 => wire__crate__api__Vault_prepare_creation_impl(port, ptr, rust_vec_len, data_len),
        50 => wire__crate__api__Vault_prepare_creation_v2_impl(port, ptr, rust_vec_len, data_len),
        51 => wire__crate__api__Vault_prepare_creation_v3_impl(port, ptr, rust_vec_len, data_len),
        52 => wire__crate__api__Vault_prepare_recovery_impl(port, ptr, rust_vec_len, data_len),
        53 => wire__crate__api__Vault_prepare_recovery_v2_impl(port, ptr, rust_vec_len, data_len),
        54 => wire__crate__api__Vault_prepare_recovery_v3_impl(port, ptr, rust_vec_len, data_len),
        55 => wire__crate__api__Vault_preview_backup_v1_impl(port, ptr, rust_vec_len, data_len),
        56 => {
            wire__crate__api__Vault_protection_settings_v1_impl(port, ptr, rust_vec_len, data_len)
        }
        57 => {
            wire__crate__api__Vault_regenerate_recovery_v3_impl(port, ptr, rust_vec_len, data_len)
        }
        58 => wire__crate__api__Vault_remove_service_v1_impl(port, ptr, rust_vec_len, data_len),
        59 => wire__crate__api__Vault_reset_application_v1_impl(port, ptr, rust_vec_len, data_len),
        60 => wire__crate__api__Vault_restore_history_v1_impl(port, ptr, rust_vec_len, data_len),
        61 => wire__crate__api__Vault_reveal_card_field_v1_impl(port, ptr, rust_vec_len, data_len),
        62 => wire__crate__api__Vault_save_account_v1_impl(port, ptr, rust_vec_len, data_len),
        63 => wire__crate__api__Vault_save_bindings_v1_impl(port, ptr, rust_vec_len, data_len),
        64 => wire__crate__api__Vault_save_card_v1_impl(port, ptr, rust_vec_len, data_len),
        65 => wire__crate__api__Vault_save_custom_card_v1_impl(port, ptr, rust_vec_len, data_len),
        66 => wire__crate__api__Vault_save_group_v1_impl(port, ptr, rust_vec_len, data_len),
        67 => wire__crate__api__Vault_save_group_v2_impl(port, ptr, rust_vec_len, data_len),
        68 => wire__crate__api__Vault_save_service_v1_impl(port, ptr, rust_vec_len, data_len),
        69 => wire__crate__api__Vault_save_template_v1_impl(port, ptr, rust_vec_len, data_len),
        70 => wire__crate__api__Vault_search_cards_v1_impl(port, ptr, rust_vec_len, data_len),
        71 => wire__crate__api__Vault_status_impl(port, ptr, rust_vec_len, data_len),
        72 => wire__crate__api__Vault_unlock_impl(port, ptr, rust_vec_len, data_len),
        73 => wire__crate__api__Vault_unlock_biometric_v1_impl(port, ptr, rust_vec_len, data_len),
        74 => wire__crate__api__Vault_unlock_v3_impl(port, ptr, rust_vec_len, data_len),
        75 => wire__crate__api__Vault_validate_recovery_v3_impl(port, ptr, rust_vec_len, data_len),
        76 => wire__crate__api__Vault_wait_for_exports_v2_impl(port, ptr, rust_vec_len, data_len),
        77 => wire__crate__api__presets__card_presets_v1_impl(port, ptr, rust_vec_len, data_len),
        79 => wire__crate__api__local_tools__local_tool_subject_v1_impl(
            port,
            ptr,
            rust_vec_len,
            data_len,
        ),
        80 => wire__crate__api__v3__password_policy_v4_impl(port, ptr, rust_vec_len, data_len),
        81 => wire__crate__api__cards__services_v1_impl(port, ptr, rust_vec_len, data_len),
        82 => wire__crate__api__v3__validate_password_v3_impl(port, ptr, rust_vec_len, data_len),
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
        39 => wire__crate__api__Vault_generation_impl(ptr, rust_vec_len, data_len),
        44 => wire__crate__api__Vault_lock_impl(ptr, rust_vec_len, data_len),
        78 => wire__crate__api__phrase__inspect_recovery_input_v1_impl(ptr, rust_vec_len, data_len),
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
impl flutter_rust_bridge::IntoDart for crate::api::account_import::AccountImportPreviewV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.token.into_into_dart().into_dart(),
            self.rows.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::account_import::AccountImportPreviewV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::account_import::AccountImportPreviewV1>
    for crate::api::account_import::AccountImportPreviewV1
{
    fn into_into_dart(self) -> crate::api::account_import::AccountImportPreviewV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::account_import::AccountImportRowV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.name.into_into_dart().into_dart(),
            self.duplicate.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::account_import::AccountImportRowV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::account_import::AccountImportRowV1>
    for crate::api::account_import::AccountImportRowV1
{
    fn into_into_dart(self) -> crate::api::account_import::AccountImportRowV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::account_import::AccountImportSourceV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::ApplePasswords => 0.into_dart(),
            Self::Authenticator => 1.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::account_import::AccountImportSourceV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::account_import::AccountImportSourceV1>
    for crate::api::account_import::AccountImportSourceV1
{
    fn into_into_dart(self) -> crate::api::account_import::AccountImportSourceV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::content::AccountInputV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.login.into_into_dart().into_dart(),
            self.password.into_into_dart().into_dart(),
            self.group_ids.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::content::AccountInputV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::content::AccountInputV1>
    for crate::api::content::AccountInputV1
{
    fn into_into_dart(self) -> crate::api::content::AccountInputV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::content::AccountRecordV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.login.into_into_dart().into_dart(),
            self.password.into_into_dart().into_dart(),
            self.group_ids.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::content::AccountRecordV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::content::AccountRecordV1>
    for crate::api::content::AccountRecordV1
{
    fn into_into_dart(self) -> crate::api::content::AccountRecordV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::content::AccountSummaryV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.group_ids.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::content::AccountSummaryV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::content::AccountSummaryV1>
    for crate::api::content::AccountSummaryV1
{
    fn into_into_dart(self) -> crate::api::content::AccountSummaryV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::AttachmentInputV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.name.into_into_dart().into_dart(),
            self.bytes.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::AttachmentInputV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::AttachmentInputV1>
    for crate::api::cards::AttachmentInputV1
{
    fn into_into_dart(self) -> crate::api::cards::AttachmentInputV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::AttachmentSummaryV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.name.into_into_dart().into_dart(),
            self.size.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::AttachmentSummaryV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::AttachmentSummaryV1>
    for crate::api::cards::AttachmentSummaryV1
{
    fn into_into_dart(self) -> crate::api::cards::AttachmentSummaryV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::backup::BackupChoiceV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.entity.into_into_dart().into_dart(),
            self.id.into_into_dart().into_dart(),
            self.resolution.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::backup::BackupChoiceV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::backup::BackupChoiceV1>
    for crate::api::backup::BackupChoiceV1
{
    fn into_into_dart(self) -> crate::api::backup::BackupChoiceV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::backup::BackupConflictV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.entity.into_into_dart().into_dart(),
            self.id.into_into_dart().into_dart(),
            self.local_name.into_into_dart().into_dart(),
            self.incoming_name.into_into_dart().into_dart(),
            self.resolution.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::backup::BackupConflictV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::backup::BackupConflictV1>
    for crate::api::backup::BackupConflictV1
{
    fn into_into_dart(self) -> crate::api::backup::BackupConflictV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::backup::BackupEntityV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Group => 0.into_dart(),
            Self::Service => 1.into_dart(),
            Self::Template => 2.into_dart(),
            Self::Card => 3.into_dart(),
            Self::History => 4.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::backup::BackupEntityV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::backup::BackupEntityV1>
    for crate::api::backup::BackupEntityV1
{
    fn into_into_dart(self) -> crate::api::backup::BackupEntityV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::backup::BackupPreviewV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.revision.into_into_dart().into_dart(),
            self.fingerprint.into_into_dart().into_dart(),
            self.added.into_into_dart().into_dart(),
            self.changed.into_into_dart().into_dart(),
            self.removed.into_into_dart().into_dart(),
            self.identical_count.into_into_dart().into_dart(),
            self.conflicts.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::backup::BackupPreviewV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::backup::BackupPreviewV1>
    for crate::api::backup::BackupPreviewV1
{
    fn into_into_dart(self) -> crate::api::backup::BackupPreviewV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::backup::BackupResolutionV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Local => 0.into_dart(),
            Self::Incoming => 1.into_dart(),
            Self::Both => 2.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::backup::BackupResolutionV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::backup::BackupResolutionV1>
    for crate::api::backup::BackupResolutionV1
{
    fn into_into_dart(self) -> crate::api::backup::BackupResolutionV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::backup::BackupStrategyV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Replace => 0.into_dart(),
            Self::Merge => 1.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::backup::BackupStrategyV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::backup::BackupStrategyV1>
    for crate::api::backup::BackupStrategyV1
{
    fn into_into_dart(self) -> crate::api::backup::BackupStrategyV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::BindingMethodV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Web => 0.into_dart(),
            Self::Rest => 1.into_dart(),
            Self::Ssh => 2.into_dart(),
            Self::Git => 3.into_dart(),
            Self::Registry => 4.into_dart(),
            Self::Database => 5.into_dart(),
            Self::Kubernetes => 6.into_dart(),
            Self::AwsCli => 7.into_dart(),
            Self::Netrc => 8.into_dart(),
            Self::Mtls => 9.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::BindingMethodV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::BindingMethodV1>
    for crate::api::catalog::BindingMethodV1
{
    fn into_into_dart(self) -> crate::api::catalog::BindingMethodV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardInputV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.service.into_into_dart().into_dart(),
            self.environment.into_into_dart().into_dart(),
            self.group_ids.into_into_dart().into_dart(),
            self.card_type.into_into_dart().into_dart(),
            self.fields.into_into_dart().into_dart(),
            self.attachment.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardInputV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardInputV1>
    for crate::api::cards::CardInputV1
{
    fn into_into_dart(self) -> crate::api::cards::CardInputV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardListRowV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.login.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardListRowV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardListRowV1>
    for crate::api::cards::CardListRowV1
{
    fn into_into_dart(self) -> crate::api::cards::CardListRowV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardMatchesV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.revision.into_into_dart().into_dart(),
            self.card_ids.into_into_dart().into_dart(),
            self.group_ids.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardMatchesV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardMatchesV1>
    for crate::api::cards::CardMatchesV1
{
    fn into_into_dart(self) -> crate::api::cards::CardMatchesV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::presets::CardPresetV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.card_type.into_into_dart().into_dart(),
            self.fields.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::presets::CardPresetV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::presets::CardPresetV1>
    for crate::api::presets::CardPresetV1
{
    fn into_into_dart(self) -> crate::api::presets::CardPresetV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardPreviewV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.row.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.protected_container.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardPreviewV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardPreviewV1>
    for crate::api::cards::CardPreviewV1
{
    fn into_into_dart(self) -> crate::api::cards::CardPreviewV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardRecordV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.summary.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.fields.into_into_dart().into_dart(),
            self.attachment.into_into_dart().into_dart(),
            self.protected_container.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardRecordV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardRecordV1>
    for crate::api::cards::CardRecordV1
{
    fn into_into_dart(self) -> crate::api::cards::CardRecordV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardRowV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.fields.into_into_dart().into_dart(),
            self.login.into_into_dart().into_dart(),
            self.otp.into_into_dart().into_dart(),
            self.attachment.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::cards::CardRowV1 {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardRowV1>
    for crate::api::cards::CardRowV1
{
    fn into_into_dart(self) -> crate::api::cards::CardRowV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardSearchV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.text.into_into_dart().into_dart(),
            self.card_type.into_into_dart().into_dart(),
            self.service.into_into_dart().into_dart(),
            self.environment.into_into_dart().into_dart(),
            self.without_environment.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardSearchV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardSearchV1>
    for crate::api::cards::CardSearchV1
{
    fn into_into_dart(self) -> crate::api::cards::CardSearchV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardSummaryV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.service.into_into_dart().into_dart(),
            self.environment.into_into_dart().into_dart(),
            self.group_ids.into_into_dart().into_dart(),
            self.card_type.into_into_dart().into_dart(),
            self.template_version.into_into_dart().into_dart(),
            self.custom_template_id.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardSummaryV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardSummaryV1>
    for crate::api::cards::CardSummaryV1
{
    fn into_into_dart(self) -> crate::api::cards::CardSummaryV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardTypeV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Account => 0.into_dart(),
            Self::Pat => 1.into_dart(),
            Self::Rsa => 2.into_dart(),
            Self::Ed25519 => 3.into_dart(),
            Self::SecretKey => 4.into_dart(),
            Self::Passphrase => 5.into_dart(),
            Self::RecoveryCodes => 6.into_dart(),
            Self::RecoveryUrl => 7.into_dart(),
            Self::SecretQa => 8.into_dart(),
            Self::Vless => 9.into_dart(),
            Self::WireGuard => 10.into_dart(),
            Self::Gpg => 11.into_dart(),
            Self::Certificate => 12.into_dart(),
            Self::OAuth => 13.into_dart(),
            Self::Dsn => 14.into_dart(),
            Self::Kubeconfig => 15.into_dart(),
            Self::WebhookSecret => 16.into_dart(),
            Self::SecureNote => 17.into_dart(),
            Self::File => 18.into_dart(),
            Self::ApiKey => 19.into_dart(),
            Self::Totp => 20.into_dart(),
            Self::AwsIam => 21.into_dart(),
            Self::GoogleCloudKey => 22.into_dart(),
            Self::AzureAppSecret => 23.into_dart(),
            Self::BearerToken => 24.into_dart(),
            Self::AppPassword => 25.into_dart(),
            Self::SshCertificate => 26.into_dart(),
            Self::KubernetesToken => 27.into_dart(),
            Self::OpenVpn => 28.into_dart(),
            Self::Ipsec => 29.into_dart(),
            Self::KeyContainer => 30.into_dart(),
            Self::ArtifactSigningKey => 31.into_dart(),
            Self::ApnsKey => 32.into_dart(),
            Self::AppStoreConnectKey => 33.into_dart(),
            Self::RegistryAccess => 34.into_dart(),
            Self::EnvironmentVariables => 35.into_dart(),
            Self::SmtpAccess => 36.into_dart(),
            Self::PresignedUrl => 37.into_dart(),
            Self::SessionCookie => 38.into_dart(),
            Self::Hotp => 39.into_dart(),
            Self::LicenseKey => 40.into_dart(),
            Self::Wifi => 41.into_dart(),
            Self::DevicePin => 42.into_dart(),
            Self::SimPinPuk => 43.into_dart(),
            Self::PaymentCard => 44.into_dart(),
            Self::BankDetails => 45.into_dart(),
            Self::IdentityDocument => 46.into_dart(),
            Self::WalletMnemonic => 47.into_dart(),
            Self::WalletPrivateKey => 48.into_dart(),
            Self::Custom => 49.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::cards::CardTypeV1 {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardTypeV1>
    for crate::api::cards::CardTypeV1
{
    fn into_into_dart(self) -> crate::api::cards::CardTypeV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::CardValueV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.value.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::CardValueV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::CardValueV1>
    for crate::api::cards::CardValueV1
{
    fn into_into_dart(self) -> crate::api::cards::CardValueV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::content::ContentSnapshotV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.revision.into_into_dart().into_dart(),
            self.groups.into_into_dart().into_dart(),
            self.accounts.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::content::ContentSnapshotV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::content::ContentSnapshotV1>
    for crate::api::content::ContentSnapshotV1
{
    fn into_into_dart(self) -> crate::api::content::ContentSnapshotV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::ContentSnapshotV2 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.revision.into_into_dart().into_dart(),
            self.groups.into_into_dart().into_dart(),
            self.cards.into_into_dart().into_dart(),
            self.services.into_into_dart().into_dart(),
            self.templates.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::ContentSnapshotV2
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::ContentSnapshotV2>
    for crate::api::cards::ContentSnapshotV2
{
    fn into_into_dart(self) -> crate::api::cards::ContentSnapshotV2 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::CustomCardInputV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.service.into_into_dart().into_dart(),
            self.environment.into_into_dart().into_dart(),
            self.group_ids.into_into_dart().into_dart(),
            self.template_id.into_into_dart().into_dart(),
            self.template_version.into_into_dart().into_dart(),
            self.accept_template_update.into_into_dart().into_dart(),
            self.values.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::CustomCardInputV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::CustomCardInputV1>
    for crate::api::catalog::CustomCardInputV1
{
    fn into_into_dart(self) -> crate::api::catalog::CustomCardInputV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::CustomFieldKindV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Text => 0.into_dart(),
            Self::Concealed => 1.into_dart(),
            Self::Url => 2.into_dart(),
            Self::Otp => 3.into_dart(),
            Self::Codes => 4.into_dart(),
            Self::File => 5.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::CustomFieldKindV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::CustomFieldKindV1>
    for crate::api::catalog::CustomFieldKindV1
{
    fn into_into_dart(self) -> crate::api::catalog::CustomFieldKindV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::CustomValueInputV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.field_id.into_into_dart().into_dart(),
            self.value.into_into_dart().into_dart(),
            self.file.into_into_dart().into_dart(),
            self.keep_file.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::CustomValueInputV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::CustomValueInputV1>
    for crate::api::catalog::CustomValueInputV1
{
    fn into_into_dart(self) -> crate::api::catalog::CustomValueInputV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::CustomValueViewV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.field_id.into_into_dart().into_dart(),
            self.value.into_into_dart().into_dart(),
            self.file.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::CustomValueViewV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::CustomValueViewV1>
    for crate::api::catalog::CustomValueViewV1
{
    fn into_into_dart(self) -> crate::api::catalog::CustomValueViewV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::EnvironmentV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Local => 0.into_dart(),
            Self::UnitTests => 1.into_dart(),
            Self::IntegrationTests => 2.into_dart(),
            Self::E2eTests => 3.into_dart(),
            Self::Development => 4.into_dart(),
            Self::Stand => 5.into_dart(),
            Self::Feature => 6.into_dart(),
            Self::Stage => 7.into_dart(),
            Self::PreRelease => 8.into_dart(),
            Self::Production => 9.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::EnvironmentV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::EnvironmentV1>
    for crate::api::cards::EnvironmentV1
{
    fn into_into_dart(self) -> crate::api::cards::EnvironmentV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::FieldIdV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Login => 0.into_dart(),
            Self::Password => 1.into_dart(),
            Self::TotpSeed => 2.into_dart(),
            Self::TotpAlgorithm => 3.into_dart(),
            Self::TotpDigits => 4.into_dart(),
            Self::TotpPeriod => 5.into_dart(),
            Self::RecoveryCodes => 6.into_dart(),
            Self::ReserveLogins => 7.into_dart(),
            Self::Value => 8.into_dart(),
            Self::PublicKey => 9.into_dart(),
            Self::PrivateKey => 10.into_dart(),
            Self::Certificate => 11.into_dart(),
            Self::ClientId => 12.into_dart(),
            Self::ClientSecret => 13.into_dart(),
            Self::AccessToken => 14.into_dart(),
            Self::RefreshToken => 15.into_dart(),
            Self::Question => 16.into_dart(),
            Self::Answer => 17.into_dart(),
            Self::KeyId => 18.into_dart(),
            Self::AccessKeyId => 19.into_dart(),
            Self::SessionToken => 20.into_dart(),
            Self::JsonKey => 21.into_dart(),
            Self::Project => 22.into_dart(),
            Self::TenantId => 23.into_dart(),
            Self::ExpiresAt => 24.into_dart(),
            Self::Namespace => 25.into_dart(),
            Self::AccountName => 26.into_dart(),
            Self::Configuration => 27.into_dart(),
            Self::Identity => 28.into_dart(),
            Self::ContainerFormat => 29.into_dart(),
            Self::TeamId => 30.into_dart(),
            Self::IssuerId => 31.into_dart(),
            Self::Endpoint => 32.into_dart(),
            Self::Variables => 33.into_dart(),
            Self::Url => 34.into_dart(),
            Self::Domain => 35.into_dart(),
            Self::CookieName => 36.into_dart(),
            Self::HotpSeed => 37.into_dart(),
            Self::Counter => 38.into_dart(),
            Self::Product => 39.into_dart(),
            Self::Ssid => 40.into_dart(),
            Self::Device => 41.into_dart(),
            Self::Pin => 42.into_dart(),
            Self::Carrier => 43.into_dart(),
            Self::Puk => 44.into_dart(),
            Self::CardNumber => 45.into_dart(),
            Self::Holder => 46.into_dart(),
            Self::ExpiryMonth => 47.into_dart(),
            Self::Iban => 48.into_dart(),
            Self::AccountNumber => 49.into_dart(),
            Self::Bic => 50.into_dart(),
            Self::DocumentType => 51.into_dart(),
            Self::DocumentNumber => 52.into_dart(),
            Self::Authority => 53.into_dart(),
            Self::Mnemonic => 54.into_dart(),
            Self::WalletPassphrase => 55.into_dart(),
            Self::Network => 56.into_dart(),
            Self::Address => 57.into_dart(),
            Self::Scopes => 58.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::cards::FieldIdV1 {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::FieldIdV1>
    for crate::api::cards::FieldIdV1
{
    fn into_into_dart(self) -> crate::api::cards::FieldIdV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::presets::FieldSpecV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.required.into_into_dart().into_dart(),
            self.concealed.into_into_dart().into_dart(),
            self.multiline.into_into_dart().into_dart(),
            self.max_bytes.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::presets::FieldSpecV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::presets::FieldSpecV1>
    for crate::api::presets::FieldSpecV1
{
    fn into_into_dart(self) -> crate::api::presets::FieldSpecV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::content::GroupInputV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.icon.into_into_dart().into_dart(),
            self.logo.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::content::GroupInputV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::content::GroupInputV1>
    for crate::api::content::GroupInputV1
{
    fn into_into_dart(self) -> crate::api::content::GroupInputV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::content::GroupRecordV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.icon.into_into_dart().into_dart(),
            self.logo.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::content::GroupRecordV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::content::GroupRecordV1>
    for crate::api::content::GroupRecordV1
{
    fn into_into_dart(self) -> crate::api::content::GroupRecordV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::HistoricalCardV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.summary.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.fields.into_into_dart().into_dart(),
            self.custom_values.into_into_dart().into_dart(),
            self.bindings.into_into_dart().into_dart(),
            self.attachment.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::HistoricalCardV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::HistoricalCardV1>
    for crate::api::catalog::HistoricalCardV1
{
    fn into_into_dart(self) -> crate::api::catalog::HistoricalCardV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::HistorySummaryV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.at.into_into_dart().into_dart(),
            self.card_id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.service.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::HistorySummaryV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::HistorySummaryV1>
    for crate::api::catalog::HistorySummaryV1
{
    fn into_into_dart(self) -> crate::api::catalog::HistorySummaryV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::cards::HotpAdvanceV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.snapshot.into_into_dart().into_dart(),
            self.code.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::cards::HotpAdvanceV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::cards::HotpAdvanceV1>
    for crate::api::cards::HotpAdvanceV1
{
    fn into_into_dart(self) -> crate::api::cards::HotpAdvanceV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::local_tools::LocalToolCommandV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Dashboard => 0.into_dart(),
            Self::Configure => 1.into_dart(),
            Self::Disconnect => 2.into_dart(),
            Self::Grant => 3.into_dart(),
            Self::Revoke => 4.into_dart(),
            Self::Request => 5.into_dart(),
            Self::PublicKey => 6.into_dart(),
            Self::AgentIdentity => 7.into_dart(),
            Self::AgentSign => 8.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::local_tools::LocalToolCommandV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::local_tools::LocalToolCommandV1>
    for crate::api::local_tools::LocalToolCommandV1
{
    fn into_into_dart(self) -> crate::api::local_tools::LocalToolCommandV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::policy::OperationV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::Reveal => 0.into_dart(),
            Self::Copy => 1.into_dart(),
            Self::Export => 2.into_dart(),
            Self::Transfer => 3.into_dart(),
            Self::IntegrationGrant => 4.into_dart(),
            Self::RecoveryKit => 5.into_dart(),
            Self::Delete => 6.into_dart(),
            Self::Protection => 7.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::policy::OperationV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::policy::OperationV1>
    for crate::api::policy::OperationV1
{
    fn into_into_dart(self) -> crate::api::policy::OperationV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::v3::PasswordPolicyStatusV4 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.minimum_length.into_into_dart().into_dart(),
            self.maximum_bytes.into_into_dart().into_dart(),
            self.uppercase.into_into_dart().into_dart(),
            self.lowercase.into_into_dart().into_dart(),
            self.digit.into_into_dart().into_dart(),
            self.special.into_into_dart().into_dart(),
            self.single_line.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::v3::PasswordPolicyStatusV4
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::v3::PasswordPolicyStatusV4>
    for crate::api::v3::PasswordPolicyStatusV4
{
    fn into_into_dart(self) -> crate::api::v3::PasswordPolicyStatusV4 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::policy::ProtectionSettingsV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.enrolled.into_into_dart().into_dart(),
            self.operations.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::policy::ProtectionSettingsV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::policy::ProtectionSettingsV1>
    for crate::api::policy::ProtectionSettingsV1
{
    fn into_into_dart(self) -> crate::api::policy::ProtectionSettingsV1 {
        self
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
impl flutter_rust_bridge::IntoDart for crate::api::v2::RecoveryChallengeV2 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.words.into_into_dart().into_dart(),
            self.positions.into_into_dart().into_dart(),
            self.choices.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::v2::RecoveryChallengeV2
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::v2::RecoveryChallengeV2>
    for crate::api::v2::RecoveryChallengeV2
{
    fn into_into_dart(self) -> crate::api::v2::RecoveryChallengeV2 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::v3::RecoveryChallengeV3 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.words.into_into_dart().into_dart(),
            self.positions.into_into_dart().into_dart(),
            self.choices.into_into_dart().into_dart(),
            self.json.into_into_dart().into_dart(),
            self.revision.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::v3::RecoveryChallengeV3
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::v3::RecoveryChallengeV3>
    for crate::api::v3::RecoveryChallengeV3
{
    fn into_into_dart(self) -> crate::api::v3::RecoveryChallengeV3 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::phrase::RecoveryInputV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.words.into_into_dart().into_dart(),
            self.invalid_positions.into_into_dart().into_dart(),
            self.complete.into_into_dart().into_dart(),
            self.recognized.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::phrase::RecoveryInputV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::phrase::RecoveryInputV1>
    for crate::api::phrase::RecoveryInputV1
{
    fn into_into_dart(self) -> crate::api::phrase::RecoveryInputV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::ResourceBindingV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.kind.into_into_dart().into_dart(),
            self.target.into_into_dart().into_dart(),
            self.method.into_into_dart().into_dart(),
            self.fields.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::ResourceBindingV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::ResourceBindingV1>
    for crate::api::catalog::ResourceBindingV1
{
    fn into_into_dart(self) -> crate::api::catalog::ResourceBindingV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::ResourceKindV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        match self {
            Self::WebApp => 0.into_dart(),
            Self::RestEndpoint => 1.into_dart(),
            Self::SshHost => 2.into_dart(),
            Self::GitRepository => 3.into_dart(),
            Self::PackageRegistry => 4.into_dart(),
            Self::ContainerRegistry => 5.into_dart(),
            Self::Database => 6.into_dart(),
            Self::KubernetesContext => 7.into_dart(),
            _ => unreachable!(),
        }
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::ResourceKindV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::ResourceKindV1>
    for crate::api::catalog::ResourceKindV1
{
    fn into_into_dart(self) -> crate::api::catalog::ResourceKindV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::ServiceDefinitionV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.description.into_into_dart().into_dart(),
            self.icon.into_into_dart().into_dart(),
            self.logo.into_into_dart().into_dart(),
            self.archived.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::ServiceDefinitionV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::ServiceDefinitionV1>
    for crate::api::catalog::ServiceDefinitionV1
{
    fn into_into_dart(self) -> crate::api::catalog::ServiceDefinitionV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::TemplateDefinitionV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.versions.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::TemplateDefinitionV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::TemplateDefinitionV1>
    for crate::api::catalog::TemplateDefinitionV1
{
    fn into_into_dart(self) -> crate::api::catalog::TemplateDefinitionV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::TemplateFieldV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.id.into_into_dart().into_dart(),
            self.label.into_into_dart().into_dart(),
            self.kind.into_into_dart().into_dart(),
            self.required.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::TemplateFieldV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::TemplateFieldV1>
    for crate::api::catalog::TemplateFieldV1
{
    fn into_into_dart(self) -> crate::api::catalog::TemplateFieldV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::catalog::TemplateVersionV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.number.into_into_dart().into_dart(),
            self.name.into_into_dart().into_dart(),
            self.fields.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive
    for crate::api::catalog::TemplateVersionV1
{
}
impl flutter_rust_bridge::IntoIntoDart<crate::api::catalog::TemplateVersionV1>
    for crate::api::catalog::TemplateVersionV1
{
    fn into_into_dart(self) -> crate::api::catalog::TemplateVersionV1 {
        self
    }
}
// Codec=Dco (DartCObject based), see doc to use other codecs
impl flutter_rust_bridge::IntoDart for crate::api::otp::TotpCodeV1 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.code.into_into_dart().into_dart(),
            self.valid_until.into_into_dart().into_dart(),
            self.period.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::otp::TotpCodeV1 {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::otp::TotpCodeV1>
    for crate::api::otp::TotpCodeV1
{
    fn into_into_dart(self) -> crate::api::otp::TotpCodeV1 {
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
impl flutter_rust_bridge::IntoDart for crate::api::v2::VaultHintsV2 {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.password.into_into_dart().into_dart(),
            self.recovery.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl flutter_rust_bridge::for_generated::IntoDartExceptPrimitive for crate::api::v2::VaultHintsV2 {}
impl flutter_rust_bridge::IntoIntoDart<crate::api::v2::VaultHintsV2>
    for crate::api::v2::VaultHintsV2
{
    fn into_into_dart(self) -> crate::api::v2::VaultHintsV2 {
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

impl SseEncode for crate::api::account_import::AccountImportPreviewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.token, serializer);
        <Vec<crate::api::account_import::AccountImportRowV1>>::sse_encode(self.rows, serializer);
    }
}

impl SseEncode for crate::api::account_import::AccountImportRowV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.name, serializer);
        <bool>::sse_encode(self.duplicate, serializer);
    }
}

impl SseEncode for crate::api::account_import::AccountImportSourceV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::account_import::AccountImportSourceV1::ApplePasswords => 0,
                crate::api::account_import::AccountImportSourceV1::Authenticator => 1,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::content::AccountInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Option<String>>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.description, serializer);
        <String>::sse_encode(self.login, serializer);
        <String>::sse_encode(self.password, serializer);
        <Vec<String>>::sse_encode(self.group_ids, serializer);
    }
}

impl SseEncode for crate::api::content::AccountRecordV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.description, serializer);
        <String>::sse_encode(self.login, serializer);
        <String>::sse_encode(self.password, serializer);
        <Vec<String>>::sse_encode(self.group_ids, serializer);
    }
}

impl SseEncode for crate::api::content::AccountSummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <Vec<String>>::sse_encode(self.group_ids, serializer);
    }
}

impl SseEncode for crate::api::cards::AttachmentInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.name, serializer);
        <Vec<u8>>::sse_encode(self.bytes, serializer);
    }
}

impl SseEncode for crate::api::cards::AttachmentSummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.name, serializer);
        <u32>::sse_encode(self.size, serializer);
    }
}

impl SseEncode for crate::api::backup::BackupChoiceV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::backup::BackupEntityV1>::sse_encode(self.entity, serializer);
        <String>::sse_encode(self.id, serializer);
        <crate::api::backup::BackupResolutionV1>::sse_encode(self.resolution, serializer);
    }
}

impl SseEncode for crate::api::backup::BackupConflictV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::backup::BackupEntityV1>::sse_encode(self.entity, serializer);
        <String>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.local_name, serializer);
        <String>::sse_encode(self.incoming_name, serializer);
        <Option<crate::api::backup::BackupResolutionV1>>::sse_encode(self.resolution, serializer);
    }
}

impl SseEncode for crate::api::backup::BackupEntityV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::backup::BackupEntityV1::Group => 0,
                crate::api::backup::BackupEntityV1::Service => 1,
                crate::api::backup::BackupEntityV1::Template => 2,
                crate::api::backup::BackupEntityV1::Card => 3,
                crate::api::backup::BackupEntityV1::History => 4,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::backup::BackupPreviewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <u64>::sse_encode(self.revision, serializer);
        <String>::sse_encode(self.fingerprint, serializer);
        <u32>::sse_encode(self.added, serializer);
        <u32>::sse_encode(self.changed, serializer);
        <u32>::sse_encode(self.removed, serializer);
        <u32>::sse_encode(self.identical_count, serializer);
        <Vec<crate::api::backup::BackupConflictV1>>::sse_encode(self.conflicts, serializer);
    }
}

impl SseEncode for crate::api::backup::BackupResolutionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::backup::BackupResolutionV1::Local => 0,
                crate::api::backup::BackupResolutionV1::Incoming => 1,
                crate::api::backup::BackupResolutionV1::Both => 2,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::backup::BackupStrategyV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::backup::BackupStrategyV1::Replace => 0,
                crate::api::backup::BackupStrategyV1::Merge => 1,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::catalog::BindingMethodV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::catalog::BindingMethodV1::Web => 0,
                crate::api::catalog::BindingMethodV1::Rest => 1,
                crate::api::catalog::BindingMethodV1::Ssh => 2,
                crate::api::catalog::BindingMethodV1::Git => 3,
                crate::api::catalog::BindingMethodV1::Registry => 4,
                crate::api::catalog::BindingMethodV1::Database => 5,
                crate::api::catalog::BindingMethodV1::Kubernetes => 6,
                crate::api::catalog::BindingMethodV1::AwsCli => 7,
                crate::api::catalog::BindingMethodV1::Netrc => 8,
                crate::api::catalog::BindingMethodV1::Mtls => 9,
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

impl SseEncode for crate::api::cards::CardInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Option<String>>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.description, serializer);
        <String>::sse_encode(self.service, serializer);
        <Option<crate::api::cards::EnvironmentV1>>::sse_encode(self.environment, serializer);
        <Vec<String>>::sse_encode(self.group_ids, serializer);
        <crate::api::cards::CardTypeV1>::sse_encode(self.card_type, serializer);
        <Vec<crate::api::cards::CardValueV1>>::sse_encode(self.fields, serializer);
        <Option<crate::api::cards::AttachmentInputV1>>::sse_encode(self.attachment, serializer);
    }
}

impl SseEncode for crate::api::cards::CardListRowV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <Option<String>>::sse_encode(self.login, serializer);
    }
}

impl SseEncode for crate::api::cards::CardMatchesV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <u64>::sse_encode(self.revision, serializer);
        <Vec<String>>::sse_encode(self.card_ids, serializer);
        <Vec<String>>::sse_encode(self.group_ids, serializer);
    }
}

impl SseEncode for crate::api::presets::CardPresetV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::cards::CardTypeV1>::sse_encode(self.card_type, serializer);
        <Vec<crate::api::presets::FieldSpecV1>>::sse_encode(self.fields, serializer);
    }
}

impl SseEncode for crate::api::cards::CardPreviewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::cards::CardRowV1>::sse_encode(self.row, serializer);
        <String>::sse_encode(self.description, serializer);
        <bool>::sse_encode(self.protected_container, serializer);
    }
}

impl SseEncode for crate::api::cards::CardRecordV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::cards::CardSummaryV1>::sse_encode(self.summary, serializer);
        <String>::sse_encode(self.description, serializer);
        <Vec<crate::api::cards::CardValueV1>>::sse_encode(self.fields, serializer);
        <Option<crate::api::cards::AttachmentSummaryV1>>::sse_encode(self.attachment, serializer);
        <bool>::sse_encode(self.protected_container, serializer);
    }
}

impl SseEncode for crate::api::cards::CardRowV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <Vec<crate::api::cards::FieldIdV1>>::sse_encode(self.fields, serializer);
        <Option<String>>::sse_encode(self.login, serializer);
        <Option<crate::api::otp::TotpCodeV1>>::sse_encode(self.otp, serializer);
        <Option<crate::api::cards::AttachmentSummaryV1>>::sse_encode(self.attachment, serializer);
    }
}

impl SseEncode for crate::api::cards::CardSearchV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.text, serializer);
        <Option<crate::api::cards::CardTypeV1>>::sse_encode(self.card_type, serializer);
        <Option<String>>::sse_encode(self.service, serializer);
        <Option<crate::api::cards::EnvironmentV1>>::sse_encode(self.environment, serializer);
        <bool>::sse_encode(self.without_environment, serializer);
    }
}

impl SseEncode for crate::api::cards::CardSummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.service, serializer);
        <Option<crate::api::cards::EnvironmentV1>>::sse_encode(self.environment, serializer);
        <Vec<String>>::sse_encode(self.group_ids, serializer);
        <crate::api::cards::CardTypeV1>::sse_encode(self.card_type, serializer);
        <u32>::sse_encode(self.template_version, serializer);
        <Option<String>>::sse_encode(self.custom_template_id, serializer);
    }
}

impl SseEncode for crate::api::cards::CardTypeV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::cards::CardTypeV1::Account => 0,
                crate::api::cards::CardTypeV1::Pat => 1,
                crate::api::cards::CardTypeV1::Rsa => 2,
                crate::api::cards::CardTypeV1::Ed25519 => 3,
                crate::api::cards::CardTypeV1::SecretKey => 4,
                crate::api::cards::CardTypeV1::Passphrase => 5,
                crate::api::cards::CardTypeV1::RecoveryCodes => 6,
                crate::api::cards::CardTypeV1::RecoveryUrl => 7,
                crate::api::cards::CardTypeV1::SecretQa => 8,
                crate::api::cards::CardTypeV1::Vless => 9,
                crate::api::cards::CardTypeV1::WireGuard => 10,
                crate::api::cards::CardTypeV1::Gpg => 11,
                crate::api::cards::CardTypeV1::Certificate => 12,
                crate::api::cards::CardTypeV1::OAuth => 13,
                crate::api::cards::CardTypeV1::Dsn => 14,
                crate::api::cards::CardTypeV1::Kubeconfig => 15,
                crate::api::cards::CardTypeV1::WebhookSecret => 16,
                crate::api::cards::CardTypeV1::SecureNote => 17,
                crate::api::cards::CardTypeV1::File => 18,
                crate::api::cards::CardTypeV1::ApiKey => 19,
                crate::api::cards::CardTypeV1::Totp => 20,
                crate::api::cards::CardTypeV1::AwsIam => 21,
                crate::api::cards::CardTypeV1::GoogleCloudKey => 22,
                crate::api::cards::CardTypeV1::AzureAppSecret => 23,
                crate::api::cards::CardTypeV1::BearerToken => 24,
                crate::api::cards::CardTypeV1::AppPassword => 25,
                crate::api::cards::CardTypeV1::SshCertificate => 26,
                crate::api::cards::CardTypeV1::KubernetesToken => 27,
                crate::api::cards::CardTypeV1::OpenVpn => 28,
                crate::api::cards::CardTypeV1::Ipsec => 29,
                crate::api::cards::CardTypeV1::KeyContainer => 30,
                crate::api::cards::CardTypeV1::ArtifactSigningKey => 31,
                crate::api::cards::CardTypeV1::ApnsKey => 32,
                crate::api::cards::CardTypeV1::AppStoreConnectKey => 33,
                crate::api::cards::CardTypeV1::RegistryAccess => 34,
                crate::api::cards::CardTypeV1::EnvironmentVariables => 35,
                crate::api::cards::CardTypeV1::SmtpAccess => 36,
                crate::api::cards::CardTypeV1::PresignedUrl => 37,
                crate::api::cards::CardTypeV1::SessionCookie => 38,
                crate::api::cards::CardTypeV1::Hotp => 39,
                crate::api::cards::CardTypeV1::LicenseKey => 40,
                crate::api::cards::CardTypeV1::Wifi => 41,
                crate::api::cards::CardTypeV1::DevicePin => 42,
                crate::api::cards::CardTypeV1::SimPinPuk => 43,
                crate::api::cards::CardTypeV1::PaymentCard => 44,
                crate::api::cards::CardTypeV1::BankDetails => 45,
                crate::api::cards::CardTypeV1::IdentityDocument => 46,
                crate::api::cards::CardTypeV1::WalletMnemonic => 47,
                crate::api::cards::CardTypeV1::WalletPrivateKey => 48,
                crate::api::cards::CardTypeV1::Custom => 49,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::cards::CardValueV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::cards::FieldIdV1>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.value, serializer);
    }
}

impl SseEncode for crate::api::content::ContentSnapshotV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <u64>::sse_encode(self.revision, serializer);
        <Vec<crate::api::content::GroupRecordV1>>::sse_encode(self.groups, serializer);
        <Vec<crate::api::content::AccountSummaryV1>>::sse_encode(self.accounts, serializer);
    }
}

impl SseEncode for crate::api::cards::ContentSnapshotV2 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <u64>::sse_encode(self.revision, serializer);
        <Vec<crate::api::content::GroupRecordV1>>::sse_encode(self.groups, serializer);
        <Vec<crate::api::cards::CardSummaryV1>>::sse_encode(self.cards, serializer);
        <Vec<crate::api::catalog::ServiceDefinitionV1>>::sse_encode(self.services, serializer);
        <Vec<crate::api::catalog::TemplateDefinitionV1>>::sse_encode(self.templates, serializer);
    }
}

impl SseEncode for crate::api::catalog::CustomCardInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Option<String>>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.description, serializer);
        <String>::sse_encode(self.service, serializer);
        <Option<crate::api::cards::EnvironmentV1>>::sse_encode(self.environment, serializer);
        <Vec<String>>::sse_encode(self.group_ids, serializer);
        <String>::sse_encode(self.template_id, serializer);
        <u32>::sse_encode(self.template_version, serializer);
        <bool>::sse_encode(self.accept_template_update, serializer);
        <Vec<crate::api::catalog::CustomValueInputV1>>::sse_encode(self.values, serializer);
    }
}

impl SseEncode for crate::api::catalog::CustomFieldKindV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::catalog::CustomFieldKindV1::Text => 0,
                crate::api::catalog::CustomFieldKindV1::Concealed => 1,
                crate::api::catalog::CustomFieldKindV1::Url => 2,
                crate::api::catalog::CustomFieldKindV1::Otp => 3,
                crate::api::catalog::CustomFieldKindV1::Codes => 4,
                crate::api::catalog::CustomFieldKindV1::File => 5,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::catalog::CustomValueInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.field_id, serializer);
        <String>::sse_encode(self.value, serializer);
        <Option<crate::api::cards::AttachmentInputV1>>::sse_encode(self.file, serializer);
        <bool>::sse_encode(self.keep_file, serializer);
    }
}

impl SseEncode for crate::api::catalog::CustomValueViewV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.field_id, serializer);
        <String>::sse_encode(self.value, serializer);
        <Option<crate::api::cards::AttachmentSummaryV1>>::sse_encode(self.file, serializer);
    }
}

impl SseEncode for crate::api::cards::EnvironmentV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::cards::EnvironmentV1::Local => 0,
                crate::api::cards::EnvironmentV1::UnitTests => 1,
                crate::api::cards::EnvironmentV1::IntegrationTests => 2,
                crate::api::cards::EnvironmentV1::E2eTests => 3,
                crate::api::cards::EnvironmentV1::Development => 4,
                crate::api::cards::EnvironmentV1::Stand => 5,
                crate::api::cards::EnvironmentV1::Feature => 6,
                crate::api::cards::EnvironmentV1::Stage => 7,
                crate::api::cards::EnvironmentV1::PreRelease => 8,
                crate::api::cards::EnvironmentV1::Production => 9,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::cards::FieldIdV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::cards::FieldIdV1::Login => 0,
                crate::api::cards::FieldIdV1::Password => 1,
                crate::api::cards::FieldIdV1::TotpSeed => 2,
                crate::api::cards::FieldIdV1::TotpAlgorithm => 3,
                crate::api::cards::FieldIdV1::TotpDigits => 4,
                crate::api::cards::FieldIdV1::TotpPeriod => 5,
                crate::api::cards::FieldIdV1::RecoveryCodes => 6,
                crate::api::cards::FieldIdV1::ReserveLogins => 7,
                crate::api::cards::FieldIdV1::Value => 8,
                crate::api::cards::FieldIdV1::PublicKey => 9,
                crate::api::cards::FieldIdV1::PrivateKey => 10,
                crate::api::cards::FieldIdV1::Certificate => 11,
                crate::api::cards::FieldIdV1::ClientId => 12,
                crate::api::cards::FieldIdV1::ClientSecret => 13,
                crate::api::cards::FieldIdV1::AccessToken => 14,
                crate::api::cards::FieldIdV1::RefreshToken => 15,
                crate::api::cards::FieldIdV1::Question => 16,
                crate::api::cards::FieldIdV1::Answer => 17,
                crate::api::cards::FieldIdV1::KeyId => 18,
                crate::api::cards::FieldIdV1::AccessKeyId => 19,
                crate::api::cards::FieldIdV1::SessionToken => 20,
                crate::api::cards::FieldIdV1::JsonKey => 21,
                crate::api::cards::FieldIdV1::Project => 22,
                crate::api::cards::FieldIdV1::TenantId => 23,
                crate::api::cards::FieldIdV1::ExpiresAt => 24,
                crate::api::cards::FieldIdV1::Namespace => 25,
                crate::api::cards::FieldIdV1::AccountName => 26,
                crate::api::cards::FieldIdV1::Configuration => 27,
                crate::api::cards::FieldIdV1::Identity => 28,
                crate::api::cards::FieldIdV1::ContainerFormat => 29,
                crate::api::cards::FieldIdV1::TeamId => 30,
                crate::api::cards::FieldIdV1::IssuerId => 31,
                crate::api::cards::FieldIdV1::Endpoint => 32,
                crate::api::cards::FieldIdV1::Variables => 33,
                crate::api::cards::FieldIdV1::Url => 34,
                crate::api::cards::FieldIdV1::Domain => 35,
                crate::api::cards::FieldIdV1::CookieName => 36,
                crate::api::cards::FieldIdV1::HotpSeed => 37,
                crate::api::cards::FieldIdV1::Counter => 38,
                crate::api::cards::FieldIdV1::Product => 39,
                crate::api::cards::FieldIdV1::Ssid => 40,
                crate::api::cards::FieldIdV1::Device => 41,
                crate::api::cards::FieldIdV1::Pin => 42,
                crate::api::cards::FieldIdV1::Carrier => 43,
                crate::api::cards::FieldIdV1::Puk => 44,
                crate::api::cards::FieldIdV1::CardNumber => 45,
                crate::api::cards::FieldIdV1::Holder => 46,
                crate::api::cards::FieldIdV1::ExpiryMonth => 47,
                crate::api::cards::FieldIdV1::Iban => 48,
                crate::api::cards::FieldIdV1::AccountNumber => 49,
                crate::api::cards::FieldIdV1::Bic => 50,
                crate::api::cards::FieldIdV1::DocumentType => 51,
                crate::api::cards::FieldIdV1::DocumentNumber => 52,
                crate::api::cards::FieldIdV1::Authority => 53,
                crate::api::cards::FieldIdV1::Mnemonic => 54,
                crate::api::cards::FieldIdV1::WalletPassphrase => 55,
                crate::api::cards::FieldIdV1::Network => 56,
                crate::api::cards::FieldIdV1::Address => 57,
                crate::api::cards::FieldIdV1::Scopes => 58,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::presets::FieldSpecV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::cards::FieldIdV1>::sse_encode(self.id, serializer);
        <bool>::sse_encode(self.required, serializer);
        <bool>::sse_encode(self.concealed, serializer);
        <bool>::sse_encode(self.multiline, serializer);
        <u32>::sse_encode(self.max_bytes, serializer);
    }
}

impl SseEncode for crate::api::content::GroupInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Option<String>>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.description, serializer);
        <String>::sse_encode(self.icon, serializer);
        <Vec<u8>>::sse_encode(self.logo, serializer);
    }
}

impl SseEncode for crate::api::content::GroupRecordV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.description, serializer);
        <String>::sse_encode(self.icon, serializer);
        <Vec<u8>>::sse_encode(self.logo, serializer);
    }
}

impl SseEncode for crate::api::catalog::HistoricalCardV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::cards::CardSummaryV1>::sse_encode(self.summary, serializer);
        <String>::sse_encode(self.description, serializer);
        <Vec<crate::api::cards::CardValueV1>>::sse_encode(self.fields, serializer);
        <Vec<crate::api::catalog::CustomValueViewV1>>::sse_encode(self.custom_values, serializer);
        <Vec<crate::api::catalog::ResourceBindingV1>>::sse_encode(self.bindings, serializer);
        <Option<crate::api::cards::AttachmentSummaryV1>>::sse_encode(self.attachment, serializer);
    }
}

impl SseEncode for crate::api::catalog::HistorySummaryV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <i64>::sse_encode(self.at, serializer);
        <String>::sse_encode(self.card_id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.service, serializer);
    }
}

impl SseEncode for crate::api::cards::HotpAdvanceV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <crate::api::cards::ContentSnapshotV2>::sse_encode(self.snapshot, serializer);
        <String>::sse_encode(self.code, serializer);
    }
}

impl SseEncode for i32 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_i32::<NativeEndian>(self).unwrap();
    }
}

impl SseEncode for i64 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        serializer.cursor.write_i64::<NativeEndian>(self).unwrap();
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

impl SseEncode for Vec<crate::api::account_import::AccountImportRowV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::account_import::AccountImportRowV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::content::AccountSummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::content::AccountSummaryV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::backup::BackupChoiceV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::backup::BackupChoiceV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::backup::BackupConflictV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::backup::BackupConflictV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::cards::CardListRowV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::cards::CardListRowV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::presets::CardPresetV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::presets::CardPresetV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::cards::CardRowV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::cards::CardRowV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::cards::CardSummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::cards::CardSummaryV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::cards::CardValueV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::cards::CardValueV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::catalog::CustomValueInputV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::CustomValueInputV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::catalog::CustomValueViewV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::CustomValueViewV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::cards::FieldIdV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::cards::FieldIdV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::presets::FieldSpecV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::presets::FieldSpecV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::content::GroupRecordV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::content::GroupRecordV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::catalog::HistorySummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::HistorySummaryV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<Vec<String>> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <Vec<String>>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::policy::OperationV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::policy::OperationV1>::sse_encode(item, serializer);
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

impl SseEncode for Vec<crate::api::catalog::ResourceBindingV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::ResourceBindingV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::catalog::ServiceDefinitionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::ServiceDefinitionV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::catalog::TemplateDefinitionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::TemplateDefinitionV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::catalog::TemplateFieldV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::TemplateFieldV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for Vec<crate::api::catalog::TemplateVersionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(self.len() as _, serializer);
        for item in self {
            <crate::api::catalog::TemplateVersionV1>::sse_encode(item, serializer);
        }
    }
}

impl SseEncode for crate::api::local_tools::LocalToolCommandV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::local_tools::LocalToolCommandV1::Dashboard => 0,
                crate::api::local_tools::LocalToolCommandV1::Configure => 1,
                crate::api::local_tools::LocalToolCommandV1::Disconnect => 2,
                crate::api::local_tools::LocalToolCommandV1::Grant => 3,
                crate::api::local_tools::LocalToolCommandV1::Revoke => 4,
                crate::api::local_tools::LocalToolCommandV1::Request => 5,
                crate::api::local_tools::LocalToolCommandV1::PublicKey => 6,
                crate::api::local_tools::LocalToolCommandV1::AgentIdentity => 7,
                crate::api::local_tools::LocalToolCommandV1::AgentSign => 8,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::policy::OperationV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::policy::OperationV1::Reveal => 0,
                crate::api::policy::OperationV1::Copy => 1,
                crate::api::policy::OperationV1::Export => 2,
                crate::api::policy::OperationV1::Transfer => 3,
                crate::api::policy::OperationV1::IntegrationGrant => 4,
                crate::api::policy::OperationV1::RecoveryKit => 5,
                crate::api::policy::OperationV1::Delete => 6,
                crate::api::policy::OperationV1::Protection => 7,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for Option<String> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <String>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::cards::AttachmentInputV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::cards::AttachmentInputV1>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::cards::AttachmentSummaryV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::cards::AttachmentSummaryV1>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::backup::BackupResolutionV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::backup::BackupResolutionV1>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::cards::CardTypeV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::cards::CardTypeV1>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::cards::EnvironmentV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::cards::EnvironmentV1>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for Option<crate::api::otp::TotpCodeV1> {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.is_some(), serializer);
        if let Some(value) = self {
            <crate::api::otp::TotpCodeV1>::sse_encode(value, serializer);
        }
    }
}

impl SseEncode for crate::api::v3::PasswordPolicyStatusV4 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.minimum_length, serializer);
        <bool>::sse_encode(self.maximum_bytes, serializer);
        <bool>::sse_encode(self.uppercase, serializer);
        <bool>::sse_encode(self.lowercase, serializer);
        <bool>::sse_encode(self.digit, serializer);
        <bool>::sse_encode(self.special, serializer);
        <bool>::sse_encode(self.single_line, serializer);
    }
}

impl SseEncode for crate::api::policy::ProtectionSettingsV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <bool>::sse_encode(self.enrolled, serializer);
        <Vec<crate::api::policy::OperationV1>>::sse_encode(self.operations, serializer);
    }
}

impl SseEncode for crate::api::RecoveryChallenge {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<String>>::sse_encode(self.words, serializer);
        <Vec<u32>>::sse_encode(self.positions, serializer);
    }
}

impl SseEncode for crate::api::v2::RecoveryChallengeV2 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<String>>::sse_encode(self.words, serializer);
        <Vec<u32>>::sse_encode(self.positions, serializer);
        <Vec<Vec<String>>>::sse_encode(self.choices, serializer);
    }
}

impl SseEncode for crate::api::v3::RecoveryChallengeV3 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<String>>::sse_encode(self.words, serializer);
        <Vec<u32>>::sse_encode(self.positions, serializer);
        <Vec<Vec<String>>>::sse_encode(self.choices, serializer);
        <String>::sse_encode(self.json, serializer);
        <u64>::sse_encode(self.revision, serializer);
    }
}

impl SseEncode for crate::api::phrase::RecoveryInputV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <Vec<String>>::sse_encode(self.words, serializer);
        <Vec<u32>>::sse_encode(self.invalid_positions, serializer);
        <bool>::sse_encode(self.complete, serializer);
        <bool>::sse_encode(self.recognized, serializer);
    }
}

impl SseEncode for crate::api::catalog::ResourceBindingV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <crate::api::catalog::ResourceKindV1>::sse_encode(self.kind, serializer);
        <String>::sse_encode(self.target, serializer);
        <crate::api::catalog::BindingMethodV1>::sse_encode(self.method, serializer);
        <Vec<String>>::sse_encode(self.fields, serializer);
    }
}

impl SseEncode for crate::api::catalog::ResourceKindV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <i32>::sse_encode(
            match self {
                crate::api::catalog::ResourceKindV1::WebApp => 0,
                crate::api::catalog::ResourceKindV1::RestEndpoint => 1,
                crate::api::catalog::ResourceKindV1::SshHost => 2,
                crate::api::catalog::ResourceKindV1::GitRepository => 3,
                crate::api::catalog::ResourceKindV1::PackageRegistry => 4,
                crate::api::catalog::ResourceKindV1::ContainerRegistry => 5,
                crate::api::catalog::ResourceKindV1::Database => 6,
                crate::api::catalog::ResourceKindV1::KubernetesContext => 7,
                _ => {
                    unimplemented!("");
                }
            },
            serializer,
        );
    }
}

impl SseEncode for crate::api::catalog::ServiceDefinitionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.name, serializer);
        <String>::sse_encode(self.description, serializer);
        <String>::sse_encode(self.icon, serializer);
        <Vec<u8>>::sse_encode(self.logo, serializer);
        <bool>::sse_encode(self.archived, serializer);
    }
}

impl SseEncode for crate::api::catalog::TemplateDefinitionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <Vec<crate::api::catalog::TemplateVersionV1>>::sse_encode(self.versions, serializer);
    }
}

impl SseEncode for crate::api::catalog::TemplateFieldV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.id, serializer);
        <String>::sse_encode(self.label, serializer);
        <crate::api::catalog::CustomFieldKindV1>::sse_encode(self.kind, serializer);
        <bool>::sse_encode(self.required, serializer);
    }
}

impl SseEncode for crate::api::catalog::TemplateVersionV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <u32>::sse_encode(self.number, serializer);
        <String>::sse_encode(self.name, serializer);
        <Vec<crate::api::catalog::TemplateFieldV1>>::sse_encode(self.fields, serializer);
    }
}

impl SseEncode for crate::api::otp::TotpCodeV1 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.code, serializer);
        <u64>::sse_encode(self.valid_until, serializer);
        <u64>::sse_encode(self.period, serializer);
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

impl SseEncode for crate::api::v2::VaultHintsV2 {
    // Codec=Sse (Serialization based), see doc to use other codecs
    fn sse_encode(self, serializer: &mut flutter_rust_bridge::for_generated::SseSerializer) {
        <String>::sse_encode(self.password, serializer);
        <String>::sse_encode(self.recovery, serializer);
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

#[cfg(not(target_family = "wasm"))]
mod io {

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
