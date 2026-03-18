# Notifly Agent Skills

A collection of skills for AI coding agents. Skills are packaged instructions and scripts that extend agent capabilities.

Skills follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

### notifly-integration

Integrate Notifly Mobile SDK into iOS, Android, Flutter, and React Native projects, and configure the Notifly MCP Server.

**Use when:**
- Integrating Notifly SDK into a new project
- Adding Notifly push notifications to an existing project
- Setting up SDK for iOS, Android, Flutter, or React Native


## Installation

```bash
npx skills add notifly-tech/skills
```

## Usage

Skills are automatically available once installed. The agent will use them when relevant tasks are detected.

**Examples:**
```
Integrate Notifly SDK into my React Native project
```
```
Set up Notifly push notifications
```
```
Verify my Notifly SDK integration
```

## Skill Structure

Each skill contains:
- `SKILL.md` - Instructions for the agent
- `scripts/` - Helper scripts for automation (optional)
- `references/` - Supporting documentation (optional)

## Disclaimer

Please be aware that these skills may occasionally fail or execute incorrectly due to the non-deterministic nature of AI. It is critical that you carefully review and verify all actions performed by these skills.

While they are designed to boost development productivity, you remain responsible for checking their output. In production environments, always review generated code and configurations before executing — especially for sensitive operations like billing, data deletion, or mass notification delivery.

## License

Each skill in this repository is governed by its own license. Please consult the `LICENSE.txt` file within each skill's directory for specific terms.
