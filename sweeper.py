from pathlib import Path
import sys
import subprocess
import shutil
from datetime import datetime
import re


if len(sys.argv) > 1:
    nome_do_tema = sys.argv[1]
else:
    nome_do_tema = "Branco"

diretorio_atual = Path.cwd()
pasta_do_tema = diretorio_atual / nome_do_tema

print(f"Diretório Atual: {diretorio_atual}")
print(f"Nome do Tema: {nome_do_tema}")
print(f"Caminho Absoluto do Tema: {pasta_do_tema}")


if pasta_do_tema.exists() and pasta_do_tema.is_dir():
    print(f"Sucesso: A pasta {pasta_do_tema} foi localizada!")
else:
    print(f"Erro: A pasta {pasta_do_tema} não foi encontrada.")
    sys.exit()


def fazer_backup(origem, destino):
    data_atual = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    pasta_backup = destino / f"backup_{data_atual}"

    try:
        shutil.copytree(origem, pasta_backup)
        print(f"Backup realizado com sucesso: {pasta_backup}")

    except Exception as e:
        print(f"Erro no backup: {e}")


def link_simbolico(src, dst):
    try:

        # Se já existir algo no destino
        if dst.exists() or dst.is_symlink():

            print(f"Removendo destino existente: {dst}")

            # Se for pasta REAL e não link
            if dst.is_dir() and not dst.is_symlink():

                print(f"{dst} é uma pasta real. Realizando backup...")

                fazer_backup(dst, pasta_reserva)

                shutil.rmtree(dst)

            else:
                dst.unlink()

        # Cria o link simbólico
        dst.symlink_to(src)

        print(f"Sucesso: Link criado -> {dst}")

    except OSError as e:
        print(f"Erro ao criar link: {e}")


origem = pasta_do_tema
pasta_config = Path.home() / ".config"
pasta_reserva = Path.home() / ".config" / "temas_backup"

pasta_reserva.mkdir(exist_ok=True)


for item in origem.iterdir():

    if item.is_dir():

        destino = pasta_config / item.name

        print("---")
        print(f"Origem: {item}")
        print(f"Destino definido: {destino}")

        link_simbolico(item, destino)

    elif item.is_file() and item.name != "sweeper.py":
        destino=pasta_config / item.name
        link_simbolico(item,destino)
        print(f"Starship Funcionando")


comandos = [
    ["hyprctl", "reload"],
    ["killall", "-SIGUSR2", "waybar"]
]

for comando in comandos:
    subprocess.run(comando)


# =========================
# Wallpaper - Hyprpaper
# =========================

pasta_wallpapers = pasta_do_tema / "wallpapers"
config_hyprpaper = Path.home() / ".config" / "hypr" / "hyprpaper.conf"

# PROCURA qualquer .png ou .jpg dentro da pasta de wallpapers
imagens = list(pasta_wallpapers.glob("*.png")) + list(pasta_wallpapers.glob("*.jpg"))

if not imagens:
    print("Nenhuma imagem .png ou .jpg encontrada na pasta de wallpapers.")
    sys.exit()

# Pega a primeira imagem encontrada como wallpaper_atual
wallpaper_atual = imagens[0]


if wallpaper_atual.exists():
    try:
        print("Ajustando hyprpaper.conf cirurgicamente...")
        
        # 1. Lê o conteúdo original do seu arquivo intacto
        conteudo_original = config_hyprpaper.read_text()

        # 2. A mágica do Regex: acha qualquer linha 'path = ...' e troca pelo caminho absoluto do tema novo
        novo_conteudo = re.sub(
            r"^\s*path\s*=.*$", 
            f"    path = {wallpaper_atual}", 
            conteudo_original, 
            flags=re.MULTILINE
        )

        # 3. Salva o arquivo preservando toda a sua estrutura de monitores e fit_mode
        config_hyprpaper.write_text(novo_conteudo)
        
        # 4. Limpa o cache do hyprpaper e aplica o novo wallpaper na hora (sem precisar dar kill)
        subprocess.run(["hyprctl", "hyprpaper", "unload", "all"], stdout=subprocess.DEVNULL)
        subprocess.run(["hyprctl", "hyprpaper", "preload", str(wallpaper_atual)], stdout=subprocess.DEVNULL)
        subprocess.run(["hyprctl", "hyprpaper", "wallpaper", f",{wallpaper_atual}"], stdout=subprocess.DEVNULL)
        subprocess.run(["pkill", "hyprpaper"])
        subprocess.Popen(["hyprpaper"])
        print(f"Sucesso: Wallpaper atualizado para {wallpaper_atual}")

    except Exception as e:
        print(f"Erro ao atualizar wallpaper: {e}")
else:
    print("Wallpaper não encontrado na pasta do tema.")
