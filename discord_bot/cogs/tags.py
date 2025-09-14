import os
import discord #type: ignore
from discord.ext import commands #type: ignore
from typing import Literal
import mysql.connector
import datetime

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getnev("DB_PORT")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_DB = os.getenv("DB_DB")

config = {
    'host': DB_HOST,
    'port': DB_PORT,
    'user': DB_USER,
    'pass': DB_PASS,
    'database': DB_DB
}

conn = mysql.connector.connect(**config)
c = conn.cursor()

class TagsCog(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    tag_group = discord.app_commands.Group(name="tag", description="Tag management commands")

    @tag_group.command(name="create", description="Creates a tag")
    async def tagcreate(self, interaction: discord.Interaction, tag_type: Literal["Headtag", "Gangtag", "Both"], label: str, ace: str):
        if interaction.user.guild_permissions.administrator:
            c.execute("SELECT * FROM discordtags WHERE label = %s AND ace = %s AND tagtype = %s", (label, ace, tag_type.lower(),))
            if c.fetchone():
                embed = discord.Embed(
                    title="Tag Create Error",
                    description=f"`{label}` already exists as a **{tag_type}** for `{ace}`",
                    color=discord.Color.green(),
                    timestamp=datetime.datetime.now()
                )
            else:
                c.execute("INSERT INTO discordtags (label, ace, tagtype) VALUES (%s, %s, %s)", (label, ace, tag_type,))
                conn.commit()
                embed = discord.Embed(
                    title="Tag Created",
                    description=f"Successfully created a **{tag_type}** `{label}` for `{ace}`",
                    color=discord.Color.green(),
                    timestamp=datetime.datetime.now()
                )
            embed.set_footer(text=f"Requested by {interaction.user.name}")
            await interaction.response.send_message(embed=embed)
        else:
            embed = discord.Embed(
                title="No Permission",
                description="You require the `ADMINISTRATOR` permission",
                color=discord.Color.red(),
                timestamp=datetime.datetime.now()
            )
            embed.set_footer(text=f"Requested by {interaction.user.name}")
            await interaction.response.send_message(embed=embed)

    @tag_group.command(name="delete", description="Delets a tag")
    async def tagdelete(self, interaction: discord.Interaction, tag: int):
        if interaction.user.guild_permissions.administrator:
            c.execute("DELETE FROM discordtags WHERE id = ?", (tag,))
            conn.commit()
            embed = discord.Embed(
                title="Tag Deleted",
                description=f"Deleted tag with ID {tag}",
                color=discord.Color.yellow(),
                timestamp=datetime.datetime.now
            )
            embed.set_footer(text=f"Requested by {interaction.user.nme}")
            await interaction.response.send_message(embed=embed)
        else:
            embed = discord.Embed(
                title="No Permission",
                description="You require the `ADMINISTRATOR` permission",
                color=discord.Color.red(),
                timestamp=datetime.datetime.now()
            )
            embed.set_footer(text=f"Requested by {interaction.user.name}")
            await interaction.response.send_message(embed=embed)

    @tagdelete.autocomplete("tag")
    async def tagdelete_tag_auto(self, interaction: discord.Interaction, current: str, /):
        if interaction.user.guild_permissions.administrator:
            c.execute("SELECT id, label, tagtype FROM discordtags")
            rows = c.fetchall()
            choices = [discord.app_commands.Choice(name=f"ID: {row[0]} | {row[1]} ({row[2]})", value=row[0]) for row in rows if row[1].startswith(current)][:25]
        else:
            choices = [discord.app_commands.Choice(name="Failed. No permissions", value=0)]
        return choices
    
    @tag_group.command(name="edit", description="Edits a tag")
    async def tagedit(self, interaction: discord.Interaction, tag: int, edit_type: Literal["Label", "Ace"], input: str):
        if interaction.user.guild_permissions.administrator:
            c.execute("SELECT label, ace, tagtype FROM discordtags WHERE id = %s", (tag,))
            row = c.fetchone()
            if row:
                if edit_type == "Label":
                    c.execute("SELECT * FROM discordtags WHERE label = %s ")
                elif edit_type == "Ace":
                    c.execute("SELECT * FROM discordtags WHERE label = %s AND ace = %S AND type = %s", (row[0], input, row[2],))
                conflict = c.fetchone()
                if conflict:
                    embed = discord.Embed(
                        title="Tag Edit Error",
                        description=f"There already exists a `{row[2].upper()}` with the label `{row[0]}` for ace `{row[1]}`",
                        color=discord.Color.red(),
                        timestamp=datetime.datetime.now()
                    )
                    embed.set_footer(text=f"Requested by {interaction.user.name}")
                    await interaction.response.send_message(embed=embed)
                    return
            c.execute(f"UPDATE discordtags SET {edit_type.lower()} = %s WHERE id = %s", (input, tag,))
            conn.commit()
            embed = discord.Embed(
                title="Tag Edit",
                description=f"Edit ID {tag}\'s {edit_type} to `{input}`",
                color=discord.Color.green(),
                timestamp=datetime.datetime.now()
            )
            embed.set_footer(text=f"Requested by {interaction.user.name}")
            await interaction.response.send_message(embed=embed)
        else:
            embed = discord.Embed(
                title="No Permission",
                description="You require the `ADMINISTRATOR` permission",
                color=discord.Color.red(),
                timestamp=datetime.datetime.now()
            )
            embed.set_footer(text=f"Requested by {interaction.user.name}")
            await interaction.response.send_message(embed=embed)

    @tagedit.autocomplete("tag")
    async def tagedit_tag_auto(self, interaction: discord.Interaction, current: str, /):
        if interaction.user.guild_permissions.administrator:
            c.execute("SELECT id, label, tagtype FROM discordtags")
            rows = c.fetchall()
            choices = [discord.app_commands.Choice(name=f"ID: {row[0]} | {row[1]} ({row[2]})", value=row[0]) for row in rows if row[1].startswith(current)][:25]
        else:
            choices = [discord.app_commands.Choice(name="Failed. No permissions", value=0)]
        return choices

    @tag_group.command(name="swap", description="Swaps a tag type")
    async def tagswap(self, interaction: discord.Interaction, tag: int, tag_type: Literal["Headtag", "Gangtag", "Both"]):
        if interaction.user.guild_permissions.administrator:
            c.execute("SELECT label, ace, tagtype FROM discordtags WHERE id = %s", (tag,))
            row = c.fetchone()
            c.execute("SELECT * FROM discordtags WHERE label = %s AND ace = %s AND tagtype = %s", (row[0], row[1], tag_type.lower(),))
            conflict = c.fetchone()
            if conflict:
                embed = discord.Embed(
                    title="Tag Swap Error",
                    description=f"There already exists a {tag_type} for the tag `{row[0]}` for `{row[1]}`",
                    color=discord.Color.red(),
                    timestamp=datetime.datetime.now()
                )
                embed.set_footer(text=f"Requested by {interaction.user.name}")
                await interaction.response.send_message(embed=embed)
                return
            c.execute("UPDATE discordtags SET tagtype = %s WHERE id = %s", (tag_type.lower(), tag,))
            conn.commit()
            embed = discord.Embed(
                title="Tag Swap",
                description=f"Successfully swapped the tag `{row[0]}` for `{row[1]}` to a {tag_type}",
                color=discord.Color.green(),
                timestamp=datetime.datetime.now()
            )
            embed.set_footer(text=f"Requested by {interaction.user.name}")
            await interaction.response.send_message(embed=embed)
        else:
            embed = discord.Embed(
                title="No Permission",
                description="You require the `ADMINISTRATOR` permission",
                color=discord.Color.red(),
                timestamp=datetime.datetime.now()
            )
            embed.set_footer(text=f"Requested by {interaction.user.name}")
            await interaction.response.send_message(embed=embed)
    
    @tagswap.autocomplete("tag")
    async def tagswap_tag_auto(self, interaction: discord.Interaction, current: str, /):
        if interaction.user.guild_permissions.administrator:
            c.execute("SELECT id, label, tagtype FROM discordtags")
            rows = c.fetchall()
            choices = [discord.app_commands.Choice(name=f"ID: {row[0]} | {row[1]} ({row[2]})", value=row[0]) for row in rows if row[1].startswith(current)][:25]
        else:
            choices = [discord.app_commands.Choice(name="Failed. No permissions", value=0)]
        return choices

async def setup(bot):
    await bot.add_cog(TagsCog(bot))