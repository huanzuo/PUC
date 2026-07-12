# PUC(INI)注释增强规范 (v2.2.1) 结构路径图

## 规范核心结构

```
ROOT (PUC标准)
├── 1. 文件基础 (标准版本、时间戳、状态)
├── 2. 分层路径结构 (PUC\路径\...)
├── 3. 三层次注释系统
│   ├── [节注释] 通过 __note__ 键
│   ├── [键注释] 键名:注释 (键后冒号)
│   └── [值注释] 值 | 注释 (竖线分隔)
├── 4. GUID系统 (二级节GUID)
└── 5. 常见应用节点
```

## 详细的路径结构层级

### Level 0: 根层 (PUC标准定义)
```
[PUC\STANDARD]
__note__ = PUC(INI)注释增强规范定义

VERSION = v2.2.1 | PUC规范版本号
CREATED = [时间戳] | 创建时间
UPDATED = [时间戳] | 最后更新时间
AUTHOR = [作者标识] | 作者或来源
STATUS = [状态标识] | 工作状态（active/draft/archive等）
```

### Level 1: 一级节点 (主要功能域)
```
[PUC\APP\通用应用]
[PUC\LIB\公共库]
[PUC\TASK\任务]
[PUC\DATA\数据]
[PUC\NOTE\笔记]
[PUC\CONFIG\配置]
[PUC\TEMPLATE\模板]
[PUC\LOG\日志]
```

### Level 2: 二级节点 (带GUID的具体实例)
```
[PUC\APP\项目A\{GUID_A}]   # 必须有自己的GUID
__note__ = 项目A的应用配置节

NAME = 项目A | 项目名称
OWNER = H.Z. | 负责人
CREATED = [时间戳] | 创建时间

[PUC\TASK\开发\{GUID_T1}]   # 必须有自己的GUID
__note__ = 开发任务配置

TASK = 实现功能X | 任务描述
PRIORITY:重要性 = high | 任务优先级
DUE = [时间戳] | 截止时间
STATUS = in_progress | 任务状态
```

### Level 3+: 更深层级 (灵活扩展)
```
[PUC\APP\项目A\{GUID_A}\MODULES\模块1]
[PUC\APP\项目A\{GUID_A}\MODULES\模块1\COMPONENTS\组件1]
[PUC\APP\项目A\{GUID_A}\MODULES\模块1\COMPONENTS\组件1\FUNCTIONS\函数1]

[PUC\TASK\开发\{GUID_T1}\SUBTASKS\子任务1]
[PUC\TASK\开发\{GUID_T1}\SUBTASKS\子任务1\STEPS\步骤1]
```

## 三层次注释示例路径图

```
[PUC\EXAMPLE\演示\{GUID_EX}]   # ← 二级节点，带GUID
│
├── 节注释 (通过 __note__ 键)
│   __note__ = 这是一个示例配置节，展示三层次注释系统
│
├── 带键注释的配置项
│   DATABASE:数据库配置 = mysql:3306 | 数据库连接信息
│   │          ↑                 ↑            ↑
│   │      键注释           值          值注释
│   │
│   CACHE:缓存设置 = redis:6379 | 缓存服务器配置
│   │
│   LOG_LEVEL:日志级别 = INFO | DEBUG/INFO/WARN/ERROR
│
├── 仅值的配置项
│   HOST = 127.0.0.1
│   PORT = 8080
│
└── 复杂结构
    USERS:用户列表 = [user1, user2, user3] | 有效用户列表
    TAGS:标签集合 = {frontend,backend,database} | 项目标签
```

## GUID生成规则路径
```
生成GUID → 验证唯一性 → 存储到[PUC\SYSTEM\GUID] → 使用到二级节点
              ↓
      [PUC\SYSTEM\GUID]
      __note__ = 全局GUID注册表
      
      GUID_EX = [生成的GUID] | 用于EXAMPLE\演示节
      GUID_T1 = [生成的GUID] | 用于TASK\开发节
      GUID_A = [生成的GUID] | 用于APP\项目A节
```

## 文件生命周期路径

```
创建新PUC文件
    ↓
添加基础元数据 ([PUC\STANDARD])
    ↓
定义一级功能节点 (APP/LIB/TASK等)
    ↓
创建二级实例节点 (带GUID)
    ↓
应用三层次注释 (节/键/值注释)
    ↓
保存到文件系统
    ↓
更新状态和时间戳
    ↓
归档或销毁
```

## 关键路径总结

1. **标准定义路径**: `PUC\STANDARD` → 元数据管理
2. **内容组织路径**: `PUC\[一级]\[二级\{GUID}]\[更深]` → 结构化管理
3. **注释应用路径**: `节(__note__) → 键(键名:注释) → 值(值 | 注释)` → 语义增强
4. **GUID管理路径**: `生成 → 注册 → 引用 → 跟踪` → 唯一性保证
5. **状态流转路径**: `创建 → 编辑 → 发布 → 归档` → 生命周期管理

---

*图例说明*:
- `[]` 表示INI节
- `{}` 表示GUID占位符
- `|` 表示值注释分隔符
- `:` 表示键注释分隔符
- `→` 表示流程方向
- `├──` `└──` 表示树形结构分支