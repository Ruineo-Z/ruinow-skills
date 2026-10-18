# BananaRouter 生图工具

需要生成图片时使用 [generate.mjs](../scripts/generate.mjs)。Node.js 20+，无额外依赖。

## 配置

推荐安装后在 Skill 根目录单独配置一次。以 `~/.agents/skills/xhs-note-creation/` 为例，将 [config.example.json](../config.example.json) 复制为同目录的 `config.local.json`，然后填写 BananaRouter 密钥：

```json
{
  "apiKey": "在这里填写你的 BananaRouter API Key"
}
```

非空环境变量 `BANANAROUTER_API_KEY` 优先于本地配置；未设置或为空时读取 `config.local.json` 的 `apiKey`。真实密钥只放在本地配置或环境变量中，不写入 Skill、提示词或 Markdown 记录。

默认服务地址为 `https://api.bananarouter.com`，模型固定为 `gpt-image-2.5-flare`。脚本不自动切换模型。

## 提示词

封面、后续配图和人物参考使用结构化 JSON 作为提示词文本。JSON 不是 API 请求体；脚本会把它作为完整的 `prompt` 字符串发送。图片设计和参考图职责见 [图片设计](photo.md) 与 [提示词与保存](prompt-and-saving.md)。

提示词必须明确每张参考图的职责：

- `model.png` 只提供人物身份，不固定表情、视线、脸部朝向或构图；
- 商品图只提供披肩外观和图中可见的上身效果，不提供商品图中模特、内搭、姿势、背景或构图；
- 场景参考图只承担地点环境、空间结构和现场痕迹；封面只承担被明确指定的服装或环境连续性。

## 调用

先完成推导，把实际发送的 JSON 保存为独立的 `.prompt.json` 文件。不要把 Markdown 记录传给脚本。

没有人物图时，先生成独立人物参考：

```bash
node <skill目录>/scripts/generate.mjs \
  --prompt-file <笔记目录>/model.prompt.json \
  --dir <笔记目录> --name model
```

封面和后续配图把 `model.png` 作为第一张参考图，商品图和本张的真实场景参考图随后传入：

```bash
node <skill目录>/scripts/generate.mjs \
  --prompt-file <笔记目录>/cover.prompt.json \
  --dir <笔记目录> --name cover \
  --image <笔记目录>/model.png \
  --image <商品图1> --image <商品图2> --image <场景参考图>
```

- `--image` 可重复，顺序必须与提示词中的 `REFERENCE_0`、`REFERENCE_1`……一致；
- 后续配图把 `--name` 换成 `1`、`2`、`3`；
- `--size` 默认 `1152x1536`（3:4），`--quality` 默认 `high`；
- 修改图片时，目标原图放第一张，使用 `cover-v2`、`1-v2` 等新名称。

## 保存与失败

笔记目录使用 `<工作目录>/YYYY-MM-DD-笔记名称/`。人物参考保存为 `model.png`、`model.md`，封面和后续配图保存为同名图片和 Markdown 记录。已有同名文件时脚本会拒绝调用。

脚本不自动重试。失败时提示词记录会保留，不写不存在的图片路径。超时或连接中断不代表服务端没有生成或没有计费，先核实调用记录再决定是否重跑。

生成成功后直接交付，由用户判断；不自动看图审核或再次生成。
