# 🎨 TEMAS - Hyprland & Wayland Configurations

Repositório de **temas completos** para ambientes baseados em Wayland, testados no **Hyprland**. Inclui configurações para Waybar, Kitty, Fastfetch, Wofi, Wlogout, Starship e wallpapers.

> ⚠️ **Este projeto está em constante evolução.** Novos temas, funcionalidades e melhorias são adicionados regularmente. O próximo grande passo é reorganizar os scripts em pastas dedicadas (`sweeper/`, `themes/`) para uma estrutura mais profissional e escalável.

---

## 🖼️ Galeria de Temas

<div align="center">
  <img src="./assets/Alucard.png" width="45%" alt="Tema Alucard">
  <img src="./assets/angel.png" width="45%" alt="Tema angel">
  <img src="./assets/Branco.png" width="45%" alt="Tema Branco">
  <img src="./assets/superman.png" width="45%" alt="Tema superman">
  <img src="./assets/roxo.png" width="45%" alt="Tema roxo">
  <img src="./assets/azul.png" width="45%" alt="Tema azul">
  <img src="./assets/darkk.png" width="45%" alt="Tema dark">
  <img src="./assets/skull.png" width="45%" alt="Tema skull">
  <img src="./assets/style.png" width="45%" alt="Tema style">
</div>

---

## 🧹 O que é o Sweeper?

O **Sweeper** é o sistema de troca de temas deste repositório, disponível em duas formas:

### CLI (`sweeper.py`)
Script Python para uso via terminal. Ideal para quem prefere linha de comando ou quer integrar em scripts.

### Gráfico (`sweeper_rofi.sh`)
Frontend visual usando **Rofi**. Oferece um menu interativo com previews de temas e wallpapers, navegação com botão "Voltar" e busca em tempo real.

### Funcionalidades (ambos):
- **Links Simbólicos Inteligentes** — cria links de `tema/` para `~/.config/`, sem copiar arquivos
- **Backup Automático** — antes de substituir pastas reais, faz backup em `~/.config/temas_backup/`
- **Hot-Reload** — recarrega Hyprland e Waybar automaticamente após a troca
- **Gestão de Wallpaper** — atualiza `hyprpaper.conf` e aplica o wallpaper sem reiniciar o compositor

---

## 📂 Estrutura do Repositório

```
TEMAS/
├── alucard/          ← tema Alucard
├── angel/            ← tema angel
├── azul/             ← tema azul
├── Branco/           ← tema Branco (padrão)
├── dark/             ← tema dark
├── roxo/             ← tema roxo
├── skull/            ← tema skull
├── style/            ← tema style
├── superman/         ← tema superman
├── assets/           ← screenshots dos temas
├── sweeper.py        ← CLI
├── sweeper_rofi.sh   ← frontend gráfico (Rofi)
├── sweeper.rasi      ← tema visual do Rofi
├── LICENSE
└── README.md
```

Cada pasta de tema contém:
```
tema/
├── fastfetch/        ← config do fastfetch
├── kitty/            ← config do Kitty (terminal)
├── waybar/           ← config do Waybar
├── wlogout/          ← config do Wlogout
├── wofi/             ← config do Wofi
├── wallpapers/       ← wallpaper do tema
├── starship.toml     ← config do Starship
└── rofi/             ← config do Rofi (se houver)
```

---

## 🚀 Instalação

### 1. Clonar o repositório

```bash
git clone https://github.com/SEU-USUARIO/TEMAS.git ~/TEMAS
cd ~/TEMAS
```

### 2. Instalar dependências

```bash
# Arch Linux / pacman
sudo pacman -S python rofi hyprpaper waybar wofi wlogout fastfetch kitty starship

# Debian / Ubuntu
sudo apt install python3 rofi waybar wofi fastfetch kitty starship
```

### 3. Aplicar um tema (CLI)

```bash
cd ~/TEMAS
python sweeper.py alucard
```

Sem argumento, aplica o tema **Branco** por padrão:
```bash
python sweeper.py
```

---

## 🎮 Usando o Frontend Gráfico (Rofi)

```bash
bash ~/TEMAS/sweeper_rofi.sh
```

O menu oferece:
- **Temas** — lista todos os temas com preview em grid
- **Wallpapers** — lista todos os wallpapers disponíveis (tema + avulsos)
- **Busca** — digite para filtrar temas/wallpapers
- **← Voltar** — navegue entre menus sem fechar o rofi

---

## ⌨️ Configuração de Binds no Hyprland

> ⚠️ **Atenção:** O Hyprland agora usa **Lua** como formato de configuração (`hyprland.conf.lua`).

### Bind para abrir o Sweeper (Rofi)

**Sintaxe antiga (`.conf`):**
```ini
bind = $mainMod, T, exec, bash ~/TEMAS/sweeper_rofi.sh
```

**Sintaxe nova (`.conf.lua`):**
```lua
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("bash ~/TEMAS/sweeper_rofi.sh"))
```

### Binds sugeridos

```lua
-- Abrir seletor de temas
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("bash ~/TEMAS/sweeper_rofi.sh"))

-- Abrir terminal
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))

-- Abrir launcher de apps
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))

-- Abrir gerenciador de logout
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("wlogout"))
```

> 💡 **Dica:** Ajuste `mainMod` para a tecla que você usa (geralmente `SUPER` ou `ALT`). Verifique seu `hyprland.conf.lua` para ver como as variáveis estão definidas.

### Recarregar configuração do Hyprland

Após editar `hyprland.conf.lua`, recarregue:
```bash
hyprctl reload
```

---

## 🛠️ Uso Avançado

### Listar temas disponíveis (CLI)

```bash
ls -d ~/TEMAS/*/ | xargs -n1 basename | grep -v -E "^(assets|\.git)$"
```

### Adicionar um novo tema

1. Crie uma pasta com o nome do tema:
```bash
mkdir ~/TEMAS/meu-tema
```

2. Copie as configs de um tema existente como base:
```bash
cp -r ~/TEMAS/alucard/* ~/TEMAS/meu-tema/
```

3. Edite os arquivos de configuração e adicione um wallpaper em `meu-tema/wallpapers/wallpaper.png`

4. O tema aparecerá automaticamente no menu do Rofi e no CLI.

### Backup manual

Os backups são salvos em `~/.config/temas_backup/`. Para restaurar manualmente:
```bash
cp -r ~/.config/temas_backup/backup_YYYY-MM-DD_HH-MM-SS/* ~/.config/
```

---

## 📋 Pré-requisitos

| Dependência | Função |
|---|---|
| `python3` | Executar o sweeper.py |
| `rofi` | Frontend gráfico |
| `hyprpaper` | Gerenciador de wallpaper |
| `waybar` | Barra de status |
| `kitty` | Terminal |
| `fastfetch` | Info do sistema |
| `wofi` | Launcher |
| `wlogout` | Menu de logout |
| `starship` | Prompt do shell |

---

## 🔮 Roadmap

- [ ] Reorganizar scripts em pastas (`sweeper/`, `themes/`)
- [ ] Suporte a temas com múltiplos monitores
- [ ] Preview de temas antes de aplicar
- [ ] Instalação automática de dependências
- [ ] Suporte a outros compositores (Sway, River)

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---

*Desenvolvido para tornar sua experiência no desktop mais fluida e estilosa.*
