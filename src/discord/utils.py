import discord
from datetime import datetime

TOKEN = 'yourToken'
GUILD_ID = 1371423884921933837         # Remplace par l’ID du serveur
IDEAS_CHANNEL_ID = 1396771954240913490 # ideas
BUGS_CHANNEL_ID = 1395684593683792025 # bugs
OPENAI_API_KEY = "yourKey"


intents = discord.Intents.default()
intents.message_content = True
intents.guilds = True
intents.messages = True

client = discord.Client(intents=intents)

from openai import OpenAI


def prompt_chatgpt(prompt, text):
    chatgpt_client = OpenAI(
        # This is the default and can be omitted
        api_key=OPENAI_API_KEY,
    )

    response = chatgpt_client.responses.create(
        model="gpt-4o",
        #instructions="You are a coding assistant that talks like a pirate.",
        input=f"{prompt}{text}",
    )
    return response.output_text

IGNORED_THREADS = ["MMA FIGHTERS Idea & Suggestion Guidelines"]

@client.event
async def on_ready():
    print(f"Connecté en tant que {client.user}")
    guild = client.get_guild(GUILD_ID)
    forum = guild.get_channel(IDEAS_CHANNEL_ID)

    all_texts = []
    ignored = 0

    print("Handling "+ str(len(forum.threads))+ " ideas")

    for thread in forum.threads:
        if thread.name not in IGNORED_THREADS:
            async for message in thread.history(limit=None, oldest_first=True):
                all_texts.append(f"{message.author.display_name}: {message.content}")
        else:
            ignored += 1


    print(f"{ignored} ignored ideas.")
    full_text = "\n".join(all_texts)

    #resume = prompt_chatgpt("Résume cette discussion Discord :\n",full_text)

    now = datetime.now().strftime("%Y-%m-%d %H%M%S")


    with open(f"{forum.name}-resume-{now}.txt", "w", encoding="utf-8") as f:
        f.write(full_text)
    await client.close()

client.run(TOKEN)
