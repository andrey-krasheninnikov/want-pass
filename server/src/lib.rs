use axum::{Router, http::header, response::IntoResponse, routing::get};

pub fn router() -> Router {
    Router::new().route("/healthz", get(health))
}

async fn health() -> impl IntoResponse {
    (
        [(header::CONTENT_TYPE, "application/json")],
        "{\"status\":\"ok\"}",
    )
}

#[cfg(test)]
mod tests {
    use super::router;
    use axum::{
        body::{Body, to_bytes},
        http::{Method, Request, StatusCode, header},
    };
    use tower::ServiceExt;

    #[tokio::test]
    async fn health_is_static_json() {
        let response = router()
            .oneshot(Request::get("/healthz").body(Body::empty()).unwrap())
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(response.headers()[header::CONTENT_TYPE], "application/json");
        let body = to_bytes(response.into_body(), 1024).await.unwrap();
        assert_eq!(body.as_ref(), br#"{"status":"ok"}"#);
    }

    #[tokio::test]
    async fn unsupported_requests_do_not_echo_input() {
        for (method, uri, status) in [
            (Method::GET, "/unknown", StatusCode::NOT_FOUND),
            (Method::POST, "/healthz", StatusCode::METHOD_NOT_ALLOWED),
        ] {
            let response = router()
                .oneshot(
                    Request::builder()
                        .method(method)
                        .uri(uri)
                        .body(Body::from("request-marker"))
                        .unwrap(),
                )
                .await
                .unwrap();
            assert_eq!(response.status(), status);
            assert!(
                to_bytes(response.into_body(), 1024)
                    .await
                    .unwrap()
                    .is_empty()
            );
        }
    }
}
