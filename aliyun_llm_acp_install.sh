#!/bin/bash

# 定义变量
ENV_NAME="llm_learn"        # 虚拟环境名称
REPO_URL="https://github.com/AlibabaCloudDocs/aliyun_acp_learning.git"  # Git 仓库地址
CLONE_DIR="aliyun_acp_learning"         # 克隆的代码目录名称
PYTHON_VERSION="3.10"           # Python 版本

# 检查 Python 是否已安装
if ! command -v python3 &> /dev/null; then
    echo "Python 未安装，请先安装 Python $PYTHON_VERSION"
    exit 1
fi

# 检查 venv 模块是否可用
if ! python3 -c "import venv" &> /dev/null; then
    echo "venv 模块不可用，请确保你的 Python 版本支持 venv"
    exit 1
fi

# 创建虚拟环境（如果环境已存在则跳过）
if [ -d "$ENV_NAME" ]; then
    echo "虚拟环境 '$ENV_NAME' 已存在，跳过创建..."
else
    echo "正在创建虚拟环境 '$ENV_NAME'..."
    python3 -m venv "$ENV_NAME" || { echo "创建虚拟环境失败"; exit 1; }
fi

# 激活虚拟环境
echo "激活虚拟环境 '$ENV_NAME'..."
source "$ENV_NAME/bin/activate" || { echo "激活虚拟环境失败"; exit 1; }

# 升级 pip
echo "升级 pip..."
pip install --upgrade pip || { echo "升级 pip 失败"; exit 1; }

# 安装 ipykernel 并注册为 Jupyter 内核（如果内核已注册则跳过）
if jupyter kernelspec list | grep -q "$ENV_NAME"; then
    echo "Jupyter 内核 '$ENV_NAME' 已注册，跳过注册..."
else
    echo "安装 ipykernel 并注册为 Jupyter 内核..."
    pip install ipykernel || { echo "安装 ipykernel 失败"; exit 1; }
    python -m ipykernel install --user --name "$ENV_NAME" --display-name "Python ($ENV_NAME)" || { echo "注册 Jupyter 内核失败"; exit 1; }
fi

# 从 Git 拉取代码
echo "从 Git 拉取代码到目录 '$CLONE_DIR'..."
if [ -d "$CLONE_DIR" ]; then
    echo "目录 '$CLONE_DIR' 已存在，跳过克隆..."
else
    git clone "$REPO_URL" "$CLONE_DIR" || { echo "Git 克隆失败"; exit 1; }
fi

# 进入代码目录
echo "进入代码目录 '$CLONE_DIR'..."
cd "$CLONE_DIR" || { echo "进入代码目录失败"; exit 1; }

# 安装依赖项
echo "安装依赖项..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt || { echo "安装依赖项失败"; exit 1; }
else
    echo "未找到 requirements.txt 文件，跳过依赖安装..."
fi

# 提示完成并退出
echo "操作完成！虚拟环境 '$ENV_NAME' 已创建并注册到 Jupyter Notebook。"

# 退出虚拟环境
deactivate
