import os
import discord
from discord.ext import commands
from dotenv import load_dotenv

load_dotenv()

TOKEN = os.getenv("DISCORD_BOT_TOKEN")

intents = discord.Intents.default()
bot = commands.Bot(command_prefix="?", intents=intents)

class MyBot(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.tree = Tree()

@bot.event()
async def setup_hook():
    print("------")
    print(f"Logged in as {bot.user} (ID: {bot.user.id})")
    print("------")
    cogs = ["tags"]
    for cog in cogs:
        try:
            await bot.load_extension(name=f"cogs.{cog}")
            print(f"Loaded {cog}\n------")
        except Exception as e:
            print(e)
    print("Loaded cogs")
    print("------")

bot.run(TOKEN)