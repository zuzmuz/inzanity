use std::path::Path;

use anyhow::{Context, Result};

use crate::domain::project::Project;

pub fn load(path: &Path) -> Result<Project> {
    let src = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read {}", path.display()))?;
    ron::from_str(&src)
        .with_context(|| format!("failed to parse {}", path.display()))
}

pub fn save(project: &Project, path: &Path) -> Result<()> {
    let pretty = ron::ser::PrettyConfig::new()
        .depth_limit(4)
        .separate_tuple_members(true)
        .enumerate_arrays(false);
    let src = ron::ser::to_string_pretty(project, pretty)
        .context("failed to serialize project")?;
    std::fs::write(path, src)
        .with_context(|| format!("failed to write {}", path.display()))
}
