# CHIM PHP Server 

Containerized deployment of [CHIM Server](https://github.com/abeiro/HerikaServer). Unless you know what you are doing, you'll probably want to grab DwemerDistro from [CHIM Skyrim Mod](https://www.nexusmods.com/skyrimspecialedition/mods/126330) instead.

## Usage

`docker pull ghcr.io/janfuu/chim-php-server:latest`  

Needs at least an additional PostgreSQL database container (with vector extensions).  
Example docker-compose.yml with xtts and minime-t5 (WIP) in [./examples](./examples)
