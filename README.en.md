# Notifly Agent Skills

A collection of skills for AI coding agents. Skills are packaged instructions and scripts that extend agent capabilities.

Skills follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

### notifly-integration

- Skill name: `notifly-integration`
- Display name: `SDK Integration`
- Path: `skills/integration`

Integrate the Notifly SDK into Mobile (iOS/Android/Flutter/React Native) and Web (JavaScript/Google Tag Manager) projects, with Notifly MCP setup and verification guidance when needed.

**Use when:**
- Integrating Notifly SDK into a new project
- Adding push notifications, in-app popups, web popups, user identity, user properties, or event tracking to an existing project
- Setting up SDK for iOS, Android, Flutter, React Native, Web, or Google Tag Manager
- Configuring Notifly MCP or verifying a Notifly SDK integration

### migrate-from-braze

- Skill name: `migrate-from-braze`
- Display name: `Migrate from Braze to Notifly`
- Path: `skills/migrate-from-braze`

Migrate Braze SDK integrations to Notifly SDK and Remote MCP-based operational workflows across iOS (Swift), Android (Kotlin/Java), Flutter, React Native, Expo, and Web projects.

**Use when:**
- Migrating CRM, push, or in-app SDK flows from Braze to Notifly
- Deciding whether to fully remove Braze now or coexist with Notifly for a period
- Accounting for empty/limited pre-SDK MCP event/property catalogs by deriving the target catalog from Braze code first
- Mapping platform-specific Braze events, user attributes, push clicks, and in-app flows to Notifly SDK/MCP workflows

### migrate-from-onesignal

- Skill name: `migrate-from-onesignal`
- Display name: `Migrate from OneSignal to Notifly`
- Path: `skills/migrate-from-onesignal`

Migrate OneSignal SDK integrations to Notifly SDK and Remote MCP-based operating flows. Supports iOS (Swift), Android (Kotlin/Java), Flutter, React Native, Expo, and Web.

**Use when:**
- Migrating CRM, push, or in-app SDK flows from OneSignal to Notifly
- Deciding between complete OneSignal removal and temporary OneSignal/Notifly coexistence
- Building a target catalog from OneSignal User Model APIs (`login`, Tags, Custom Events, Subscriptions) and legacy APIs
- Mapping OneSignal SDK structure such as web service workers, Expo plugins, iOS NSE/App Groups, and Android FCM services to Notifly


## Installation

Install the full skill package:

```bash
npx skills add notifly-tech/skills
```

Install all skills to all supported agents without prompts:

```bash
npx skills add notifly-tech/skills --all
```

List the individual skills available in this repository:

```bash
npx skills add notifly-tech/skills --list
```

To install only specific skills, pass the **skill name** after `--skill`.

```bash
# Install only the Notifly SDK integration skill
npx skills add notifly-tech/skills --skill notifly-integration

# Install only the Braze → Notifly migration skill
npx skills add notifly-tech/skills --skill migrate-from-braze

# Install only the OneSignal → Notifly migration skill
npx skills add notifly-tech/skills --skill migrate-from-onesignal

# Install multiple specific skills at once
npx skills add notifly-tech/skills --skill notifly-integration migrate-from-braze migrate-from-onesignal
```

You can combine individual skill installation with standard `npx skills` scope/agent options.

```bash
npx skills add notifly-tech/skills --skill migrate-from-braze --agent claude-code
npx skills add notifly-tech/skills --skill migrate-from-onesignal --agent claude-code
npx skills add notifly-tech/skills --skill migrate-from-braze --global
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
```
Migrate from OneSignal to Notifly
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
