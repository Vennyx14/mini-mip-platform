from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_repository_foundation_exists() -> None:
    required = [
        "AGENTS.md",
        "CLAUDE.md",
        "README.md",
        "pyproject.toml",
        "src/mip",
        "apps/api",
        "configs",
        "deployments/mlflow",
        "deployments/kserve",
        "deployments/litellm",
        "docs",
        "tests/unit",
        "tests/integration",
        "tests/e2e",
    ]

    missing = [path for path in required if not (ROOT / path).exists()]
    assert not missing, f"Missing repository foundation paths: {missing}"
