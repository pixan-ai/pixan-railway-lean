# pixan-railway-lean

[English](README.md) · **Español**

Lo **mínimo** para que nazca un agente de [Claude Code](https://docs.anthropic.com/claude-code) en
[Railway](https://railway.com) y te conteste por Telegram. Unas 170 líneas el agente en sí (sin contar pruebas): se lee en 20
minutos. Lo extra se agrega después, una pieza a la vez y solo si hace falta (ver [DESIGN.md](DESIGN.md)).

## Qué hay aquí

```
Dockerfile            La caja: Debian + Claude Code + Bun (lo pide el plugin de Telegram) + tmux
railway.toml          Constrúyelo con el Dockerfile; si se cae, levántalo otra vez
entrypoint.sh         El arranque en 7 pasos (léelo: está comentado)
config/settings.json  Reglas de Claude: plugin de Telegram, prohibiciones, hora de CDMX
config/access.json    Quién puede escribirle al bot: solo el dueño
workspace/CLAUDE.md   Instrucciones del agente; carga @SOUL.md e @IDENTITY.md
workspace/SOUL.md     Personalidad (se escribe una vez; luego es del dueño)
workspace/IDENTITY.md Datos fijos: nombre, canal, zona horaria
tests/                Pruebas de aceptación L0–L3 (ver tests/README.md)
```

El código y los comentarios están en inglés. El agente te habla en el idioma de `AGENT_LANGUAGE`;
por default, español de México, de tú.

## Crear un agente nuevo

1. **Credencial de Claude.** En tu computadora corre `claude setup-token`, inicia sesión y copia el
   token (dura un año). No lo pegues en ningún chat ni archivo.
2. **Bot de Telegram.** Habla con [@BotFather](https://t.me/BotFather), manda `/newbot`, elige nombre
   y usuario, y copia el token del bot.
3. **Tu ID de Telegram.** Escríbele a [@userinfobot](https://t.me/userinfobot): te contesta un número.
4. **Railway.** New Project → Deploy from GitHub repo → este repo. En el servicio:
   - Un **volumen** montado en **`/data`** (ahí viven la memoria, la plática, el alma y la allowlist).
   - **Variables:**

     | Variable | Valor | ¿Obligatoria? |
     |---|---|---|
     | `CLAUDE_CODE_OAUTH_TOKEN` | el token del paso 1 | sí |
     | `TELEGRAM_BOT_TOKEN` | el token del paso 2 | sí |
     | `OWNER_TELEGRAM_ID` | el número del paso 3 | sí |
     | `AGENT_NAME` | el nombre del agente, en minúsculas | no (`agent`) |
     | `AGENT_LANGUAGE` | idioma en que habla, texto simple | no (español de México, de tú) |
5. **Deploy.** Si falta una llave, el log dice `MISSING …` y se detiene. Es a propósito.

Los secretos viven **solo** en las Variables de Railway, nunca en este repo.

## Prueba de aceptación

`./tests/l0-static.sh` y `./tests/l1-unit.sh` corren en cualquier Linux; el CI además corre la capa
con Docker. Ya desplegado, la prueba de verdad es la lista L3 de [tests/README.md](tests/README.md):
**escríbele y que te conteste.** El latido solo demuestra que el proceso existe, no que esté vivo.

## Licencia

[MIT](LICENSE). Problemas de seguridad: ver [SECURITY.md](SECURITY.md).
