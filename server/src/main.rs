use std::net::Ipv4Addr;
use tokio::net::TcpListener;

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let listener = TcpListener::bind((Ipv4Addr::LOCALHOST, 3000)).await?;
    println!("Want Pass backend listening on 127.0.0.1:3000");
    axum::serve(listener, want_pass_server::router()).await?;
    Ok(())
}
