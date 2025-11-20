[![Zig](https://img.shields.io/badge/Zig-F7A41D?logo=zig&logoColor=fff)](#)
[![Minecraft](https://img.shields.io/badge/Minecraft-1.21.10-green?style=social&logo=minecraft)](https://minecraft.wiki/w/Java_Edition_1.21.10)
[![License](https://img.shields.io/github/license/tn-lorenz/kommodo?style=social)](https://github.com/tn-lorenz/kommodo/blob/main/LICENSE) 
[![Docs](https://img.shields.io/badge/docs-GitHub_Pages-blue)](https://tn-lorenz.github.io/kommodo/)
[![Tests](https://github.com/4lve/SteelMC/actions/workflows/test.yml/badge.svg)](#)
[![Lint](https://github.com/4lve/SteelMC/actions/workflows/lint.yml/badge.svg)](#)
[![Build](https://github.com/4lve/SteelMC/actions/workflows/release.yml/badge.svg)](#)


<div align="center">

# Kommodo

   <p align="center" width="66%">
     <img src="https://www.abc4.com/wp-content/uploads/sites/4/2023/06/Komodo_027.jpg" alt="Logo" width="66%">
   </p>

Kommodo is an ECS-based Minecraft server, built in zig `0.15.2`.
*Note that further work will be put into this, once the new `std.Io` interface stabilizes.*
</div>

---

## 📖 Table of Contents

- [How to contribute](#how-to-contribute)
  - [Identify](#identify)
  - [Decompile](#decompile)
  - [Fork](#fork)
  - [Examine](#examine)
  - [Commit](#commit)
- [Design decisions](#design-decisions)
  - [Why ECS?](#why-ecs)
  - [Why the lib?](#why-the-lib)
  - [Why zig?](#why-zig)
- [Goals](#goals)
- [License](#license)

---

## How to contribute
> [!NOTE]
> All the following steps require you to have a version of [git](https://git-scm.com/) and [zig 0.15.2](https://www.zvm.app/) running on your system.

## Identify
... a feature you'd like to add or an issue to work on. You should always create an issue or a draft-pr describing what you want, before considering adding a major feature.

## Decompile
... the latest version of Minecraft using Parchment mappings. The `main` branch currently targets Minecraft `1.21.10`.

Alternatively, you may use [GitCraft](https://github.com/WinPlay02/GitCraft) for this task.
If you choose to use GitCraft, run the command 
```bash
./gradlew run --args="--mappings=mojmap_parchment --only-stable"
```
in the GitCraft directory and keep in mind that you *may* have to implement this [change](https://github.com/WinPlay02/GitCraft/pull/29) beforehand.

## Fork
... the `main` branch of this repository, so you can prepare your changes on there. Clone it to your system by running the command
```gitattributes
git clone https://github.com/{your-name}/kommodo
```
in your directory of choice. And don't forget to set this repository as it's upstream by running the following command
```gitattributes
git remote add upstream https://github.com/tn-lorenz/kommodo.git
```
in said directory. To test if it has succeeded, type
```gitattributes
git remote -v
```
which should yield the following.
```gitattributes
origin   https://github.com/{your-name}/kommodo.git (fetch)
origin   https://github.com/{your-name}/kommodo.git (push)
upstream https://github.com/tn-lorenz/kommodo.git (fetch)
upstream https://github.com/tn-lorenz/kommodo.git (push)
```
Now set-up a new feature branch by running
```gitattributes
git checkout -b feat-{feature-name}
```
from the `main` branch.

## Examine
... the vanilla Minecraft implementation. Translate it to idiomatic, ECS-compatible `zig 0.15.2` code, as cleanly and efficiently as possible (SIMD would be goated!).
When in doubt, consider if your code adheres to the [core-principles](#design-decisions) and [goals](#goals) of this project.

## Commit
... your changes to your fork and use the following commands in its directory:
```gitattributes
git add .
git commit -m "{your-message}"
git push origin {your-branch}
```
Then you may open a pull-request by comparing on the github website.
> [!NOTE]
> This project strictly enforces the use of the [conventional commits standard](https://www.conventionalcommits.org/en/v1.0.0/) in the commit messages.
---

## Design decisions
This section briefly explains the thought-process behind the key-principles of this project's design.

## Why ECS
A Entity-Component-System (ECS)-based architecture allows for data-oriented-design, cache optimisation, easy parallelization and massive concurrency.
It should also be easy and ergonomic to work with, thanks to `zig`'s [comptime](https://ziglang.org/documentation/0.15.2/#comptime) capabilities.

## Why the lib
Kommodo aims for providing both a fully-working implementation of the current Minecraft vanilla server, complete with plugin support and a library that allows for bespoke implementations, similar to [Minestom](https://github.com/Minestom/Minestom).

## Why zig
As previously noted, `zig` provides great utility with it's compile-time capabilities. The new `std.Io` interface enables a high level of customization, for example switching to an event-based
async runtime, as provided by `libxev` would be trivial. Being a low-level language, it's also more than suitable for thorough optimization.

---

## Goals
- [ ] Provide a native, easy to use, flexible and powerful ECS library
- [ ] Provide a fully-implemented example of a vanilla server with plugin support as a downloadable binary
- [ ] highly optimise for data-oriented-design, multi-threading, parallelisation, SIMD and customization
- [ ] Utilise the full power of the `Io` interface and event-based runtimes

---

## License
This project and all of its content is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).
