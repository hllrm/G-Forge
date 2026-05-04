## Python ML Architecture Rules

**Layer map:**
- `data/` — Dataset classes, DataLoaders, transforms, preprocessing; no model imports
- `models/` — architecture definitions only (`nn.Module` / sklearn estimators); no training logic, no loss in `forward()`
- `training/` — train loops, loss computation, optimizer steps, schedulers; calls models and data; no hardcoded hyperparams
- `evaluation/` — metrics and validation loops; always `model.eval()` + `torch.no_grad()`; no training imports
- `inference/` — prediction pipeline; loads checkpoint + config; no training imports
- `config/` — all hyperparameters and paths as Pydantic or dataclass objects; no magic numbers elsewhere
- `utils/` — seeding, checkpoint I/O, logging helpers, device utilities

**Import direction:** training → models, data, config, utils. Evaluation → models, data, config. Inference → models, config, utils. Data → config, utils. Never upward.

**Hardcoded hyperparameter rule:** Learning rate, batch size, epochs, hidden dimensions, dropout, and all numeric knobs must live in config objects. Any literal numeric value for these in training or model files is a blocking violation.

**Reproducibility rule:** Every training entry point must call `set_seed(cfg.seed)` before any data loading or model initialization, and must log all config params to an experiment tracker (MLflow, W&B, TensorBoard, or CSV).

**Model rule:** `forward()` computes the forward pass only — no loss, no optimizer step, no data loading. Training logic does not belong in model classes.

**Evaluation rule:** Validation loops always set `model.eval()` and run inside `torch.no_grad()`. Metrics are computed in `evaluation/` and returned as a dict, not printed inline in the training loop.

**Inference rule:** Inference always loads model architecture config from the checkpoint — never hardcodes dimensions. `model.train()` is never called in inference code.
