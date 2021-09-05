use rid_build::{build, BuildConfig, BuildTarget, Project};
use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR")
        .expect("Missing CARGO_MANIFEST_DIR, please run this via 'cargo run'");

    let crate_name = &env::var("CARGO_PKG_NAME")
        .expect("Missing CARGO_PKG_NAME, please run this via 'cargo run'");

    let lib_name = &format!("lib{}", &crate_name);

    let build_config = BuildConfig {
        target: BuildTarget::Debug,
        project: Project::Dart,
        lib_name,
        crate_name,
        project_root: &crate_dir,
        workspace_root: Some(&crate_dir),
    };
    let build_result = build(&build_config).expect("Build failed");

    eprintln!("{}", build_result);
}
