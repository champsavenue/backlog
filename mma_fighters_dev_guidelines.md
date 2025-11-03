# MMA Fighters Development Guidelines

## 1. General Rules
- All scripts **must start** with the standard header format:
  ```lua
  --======================================================================
  --  File: <Service>/<ScriptName>.lua
  --
  --  Description:
  --      <Brief explanation of the script purpose>
  --
  --  Author(s): <Name(s)>
  --
  --  Last Modified: <YYYY-MM-DD> by <Author>
  --
  --  Version: V<YYYY-MM>
  --
  --  Dependencies:
  --      - ReplicatedStorage:
  --          * <Modules used>
  --      - Roblox Services:
  --          * <Services used>
  --      - External:
  --          * <External APIs>
  --
  --  Notes:
  --      - <Additional remarks>
  --======================================================================
  ```

- All functions must be documented with a short comment.
- Avoid inline logic: encapsulate everything in functions or event callbacks.
- No permanent `print()` calls
- Maintain a single source of truth for game constants and helper function in `ReplicatedStorage/Modules/Utils.lua`. 
- Maintain a single source of truth for player constants and helper function in `ReplicatedStorage/Modules/PlayerUtils.lua`. 
- Split long scripts (>500 lines) into smaller modules for maintainability.
- Always include version and last modification info in headers and maintain the dependencies and comments
- Use `task.spawn` or `RunService`-based coroutines instead of `wait()`.
- Document inter-module dependencies clearly.

### Naming Conventions Summary

- Use **PascalCase** for folders and scripts, **camelCase** for variables, **UPPER_SNAKE_CASE** for constants.

| Type              | Convention Example         |
|-------------------|----------------------------|
| Folder            | `PlayerSystems`            |
| ModuleScript      | `Buttons_Mod`              |
| RemoteEvent       | `Convert_Cash_To_Gems`     |
| RemoteFunction    | `Claim_Daily_Reward`       |
| Template Model    | `Skeleton_Zombie`          |
| UI Element        | `Gym_Training_Handle_UI`   |
| Local variable    | `posMin`                   |
| Constant          | `VERSION`                  |

---

## 2. Workspace
**Path:** `Workspace/`

**Existing structure:**
```
Workspace/Main_World_F
	├── Environment
	│ ├── Art
	│ ├── Collisions
	│ └── Spawns
	├── Gameplay
	│ ├── Animations
	│ └── Objects
	│ │ └── Bots
	│ │ └── Fight_Cages_F
	│ │ └── GymObjects
	│ │ └── Leaderboards
	│ │ └── Octagons
	│ │ └── Rankings
	│ │ └── Regions
	│ │ └── TeleportPads
	│ │ └── Tutorial_Parts_F
	├── Shop
	│ ├── ATM
	│ ├── Crates
	│ ├── DisplayItems
	│ ├── Offers_Data
	│ └── OpenColliders
	└── UGC
	  ├──Halloween
	  └──Standard
```
### Notes & Conventions
- **Main_World_F**: main container for all in-game physical assets.
- **Environment**: contains static world assets (maps, terrain, props).
- **Gameplay**: houses gameplay mechanics, interactive objects, and animations.
- **Shop**: holds all shop-related items and systems (ATM, Crates, Offers).
- **UGC**: user-generated content; categorized by event or theme (e.g., Halloween).

**Rules:**
- Only **physical and interactive objects** should exist here.
- Never add new element at the root level, always create them in the adequate folder
- No scripts should reside directly in `Workspace`. Use references from `ServerScriptService` or replicated modules.
- Temporary effects (explosions, particles, VFX) must be spawned via utility modules and auto-destroyed.

---

## 3. ReplicatedStorage
**Path:** `ReplicatedStorage/`

Used for **shared logic, RemoteEvents, and constants** accessible by both server and client.

**Existing structure:**
```
ReplicatedStorage
├── Animation_Objs_F
├── Channels_F
│ ├── Bindable_F
│ ├── Client_Server_F
│ └── Server_Client_F
├── Data_Mods_F
├── Design
│ ├── Sound_Groups
│ └── Themes
│ ├── Buttons_Mod
│ ├── LockManager
│ └── ThemeManager
├── Models
│ ├── Clothing_F
│ ├── GymEventAssets
│ ├── Tournaments
│ └── UGC
├── Modules
│ ├── Channels
│ ├── CreatorCodes
│ ├── GameAnalytics
│ └── PlayerUtils
│ └── Utils
```
### Notes & Conventions
- **Animation_Objs_F** → Stores reusable animation sequences and animation controllers accessible from both client and server.  
- **Channels_F** → Centralized folder for inter-service communication:  
  - `Bindable_F` → Internal server-only bindable events/functions.  
  - `Client_Server_F` → RemoteEvents/Functions triggered by clients and handled server-side.  
  - `Server_Client_F` → RemoteEvents/Functions emitted from the server to clients.  
- **Data_Mods_F** → Contains data modules for cosmetics, outfits, and power-ups.  
- **Design** → Groups all design-related resources:
  - `Sound_Groups` → Preset groups for volume balancing.
  - `Themes` → Theme management system (UI color schemes, layouts, and styles).  
- **Models** → Shared models available for replication (clothing, event props, tournament structures).  
- **Modules** → Core shared logic and utility scripts:
  - `Channels` → Handles registration and management of RemoteEvents.
  - `CreatorCodes` → Logic for handling creator or referral codes.
  - `GameAnalytics` → Tracks gameplay metrics.
  - `PlayerUtils` → Helper functions for player state management.
  - `Utils` → Miscellaneous shared helpers (e.g., math, strings, or logging).
  
**Guidelines:**
- Modules must return a table exposing clear, documented methods.
- Avoid `wait()`. Use `RunService.Heartbeat` or bindable events for synchronization.
- Store all shared RemoteEvents and RemoteFunctions under `Channels_F`.
- Place any shared data models (skins, outfits, power-up stats) under `Data_Mods_F`.
- Centralize universal values (colors, rewards, item IDs) in `Constants.lua`.

---

## 4. ServerScriptService
**Path:** `ServerScriptService/`

Hosts the **server logic** for combat management, player progression, API integrations, and data persistence.

**Existing structure:**
```
ServerScriptService
├── Core
│ ├── Datastore
│ ├── Monetization
│ ├── Player
│ └── System
│   ├── Bloxlink
│   ├── Server_List_Handle
│   └── Video_Player
├── Fight_Service
├── League_Service
└── Modules
│   ├── Codes_Unique
│   ├── GAModule
│   ├── GlobalLeaderBoards
```

### Notes & Conventions

- **Core** → Central systems managing player lifecycle, economy, and backend communication.  
  - `Datastore` → Handles data persistence and secure saving/loading of player profiles.  
  - `Monetization` → Processes premium purchases, Robux transactions, and in-game rewards.  
  - `Player` → Controls player initialization, cleanup, and data synchronization.  
  - `System` → Global services for integrations and server-level utilities:
    - `Bloxlink` → Discord verification and role synchronization.
    - `Server_List_Handle` → Manages visible server lists or matchmaking registration.
    - `Video_Player` → Handles video playback or media streaming logic.
- **Fight_Service** → Main gameplay logic for fights, movesets, stamina, and hit detection.  
- **League_Service** → Manages competitive systems such as rankings, divisions, or event scheduling.  
- **Modules** → Shared server-only logic:
  - `Codes_Unique` → Manages redemption and tracking of unique promotional codes.
  - `GAModule` → Server-side analytics, events tracking, and telemetry.
  - `GlobalLeaderBoards` → Cross-server ranking synchronization.

**Guidelines:**
- Each script must follow the header format above.
- All API keys or secrets must be stored securely (`HttpService:GetSecret`).
- Each main system (Combat, Economy, PlayerData) should be self-contained and decoupled via RemoteEvents.

---

## 5. ServerStorage
**Path:** `ServerStorage/`

Contains **templates, preloaded models, and secure data** not accessible by the client.

**Existing structure:**
```
ServerStorage
├── Debug
├── Global_Sounds_F
├── Rewards
│ ├── 2xCash
│ ├── HugeMoneyPack
│ ├── LargediamondsPack
│ └── VIP
└── Training_Bots
  ├── Halloween
  └── Standard
```

### Notes & Conventions

- **Debug** → Used for internal testing or administrative tools. Must be excluded from production builds if not essential.  
- **Global_Sounds_F** → Centralized storage for global sound assets used across the game (announcer voice lines, ambience, crowd effects).  
- **Rewards** → Scripted assets representing in-game packs or premium bonuses:  
- **Training_Bots** → Models and templates for training or tutorial sessions.  
  - `Halloween` / `Standard` → Seasonal or themed variants of training bots.  

**Guidelines:**
- Only templates, backup data and debug scripts — no active scripts.
- Scripts may clone these models but never modify them directly in place.
- ServerStorage must not be referenced by clients.

---

## 6. StarterGui
**Path:** `StarterGui/`

Holds **all player-facing UI components**: menus, HUD, notifications.

**Existing structure:**
```
StarterGui
├── Fight
│ ├── Idle_Fight_Buttons
│ ├── Damage_Effect_UI
│ ├── Fight_Intro_UI
│ ├── Fight_Result_UI
│ ├── Fight_System_UI
│ ├── Fight_Teleport_UI
│ └── Stamina_Down_UI
├── Menus
│ ├── Codes_UI
│ ├── Combination_UI
│ ├── Daily_Rewards_UI
│ ├── HUD
│ ├── League_UI
│ ├── Player_Stats_UI
│ ├── Rewards_UI
│ ├── Servers_UI
│ └── Skill_Tree_UI
├── Player
│ └── Gym_Training_Handle_UI
├── Shop
│ ├── CreatorCode
│ ├── Halloween_UGCs_Shop_UI
│ ├── InsufficientFunds_UI
│ ├── Offer_UI
│ ├── Shop_UI
│ └── Starter_Pack_UI
└── System
  ├── Check_Screen_Orientation
  ├── Changelog_UI
  ├── Elo_Limit_UI
  ├── Emotes_UI
  ├── Hole_Transition_UI
  ├── Notification_UI
  ├── Player_List_UI
  ├── Settings_UI
  ├── Sound_Effects_F
  ├── Tutorial_UI
  └── White_Crate_Fade_UI
```
### Notes & Conventions

- **Fight** → Contains all combat-related UI elements, such as intros, stamina, and result screens.  
- **Menus** → Centralized player navigation and stats views.  
  - All UIs must be connected to RemoteEvents through `ReplicatedStorage/Modules/Channels  
- **Player** → Player-specific interfaces for training or progression
- **Shop** → Interfaces related to in-game purchases and offers.  
- **System** → Technical and meta-level UI elements:  

  
**Guidelines:**
- Only `LocalScripts` here — no `Script` instances.
- Connect to RemoteEvents via:
  ```lua
  local Channels 				= require(RS:WaitForChild("Modules"):WaitForChild("Channels"))
  -- Use centralized references from Channels
  local Display_Data_E 			= Channels.Bindable_Events.Display_Data
  local Toggle_Side_Buttons 	= Channels.Bindable_Events.Toggle_Side_Buttons
  local Open_Stats 				= Channels.Bindable_Events.Open_Stats
  local Open_Appearance 		= Channels.Bindable_Events.Open_Appearance
  ```
- GUI naming convention: `<Context>_UI` (e.g., `Changelog_UI`, `Halloween_UGCs_Shop_UI`).
- GUI should be resolution-independent (use `UIScale` or anchor points).

---

**Author:** Darkzeb  
**Version:** V2025-11  
**Last Updated:** 2025-11-03