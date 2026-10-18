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

使用参考图时，提示词应明确各图的职责：

- `model.png` 提供需要延续的人物身份，不自动固定表情、服装或构图；
- 商品图提供本次需要保持的商品外观、结构或使用状态；
- 场景参考图提供需要复现的地点、空间关系或现场条件；其他参考只继承用户明确指定的部分。

## 调用

先完成推导，把实际发送的 JSON 保存为独立的 `.prompt.json` 文件。不要把 Markdown 记录传给脚本。

需要保持人物身份而没有人物图时，可先生成独立人物参考：

```bash
node <skill目录>/scripts/generate.mjs \
  --prompt-file <笔记目录>/model.prompt.json \
  --dir <笔记目录> --name model
```

需要参考图时，将它们按提示词顺序传入。以下示例包含人物、商品和场景三类参考；实际任务可省略不需要的图片：

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
