#!/usr/bin/env bash
# =============================================================================
# sweeper_rofi.sh
# -----------------------------------------------------------------------------
# Frontend rofi para o sweeper.py
#
# Estrutura de diretórios suportada:
#
#   DIR/
#   ├── sweeper.py
#   ├── sweeper_rofi.sh
#   ├── wallpapers/          ← pasta raiz opcional de wallpapers avulsos
#   │   ├── foto.png
#   │   └── outro.jpg
#   ├── alucard/
#   │   └── wallpapers/      ← wallpapers do tema alucard
#   │       └── wallpaper.png
#   ├── dark/
#   │   └── wallpapers/
#   │       └── wallpaper.png
#   └── ...
#
# Uso:
#   bash sweeper_rofi.sh
#
# Atalho no hyprland.conf:
#   bind = $mainMod, T, exec, bash /caminho/para/TEMAS/sweeper_rofi.sh
#
# Dependências:
#   rofi   (pacman -S rofi)
#   python (para chamar sweeper.py)
# =============================================================================

# ── Configuração ──────────────────────────────────────────────────────────────

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWEEPER="$DIR/sweeper.py"
ESTADO="$DIR/.estado_atual"
TEMA_ROFI="$DIR/sweeper.rasi"

# Pastas a ignorar ao listar temas
IGNORAR=(".git" "assets" "wallpapers")

# ── Helpers de estado ─────────────────────────────────────────────────────────

ler_estado() {
    local chave="$1"
    [[ -f "$ESTADO" ]] && grep "^${chave}=" "$ESTADO" | cut -d'=' -f2-
}

salvar_estado() {
    local chave="$1" valor="$2"
    touch "$ESTADO"
    if grep -q "^${chave}=" "$ESTADO" 2>/dev/null; then
        sed -i "s|^${chave}=.*|${chave}=${valor}|" "$ESTADO"
    else
        echo "${chave}=${valor}" >> "$ESTADO"
    fi
}

deve_ignorar() {
    local nome="$1"
    for item in "${IGNORAR[@]}"; do
        [[ "$nome" == "$item" ]] && return 0
    done
    return 1
}

# Acha o melhor preview de um tema (prioriza wallpapers/wallpaper.*)
achar_preview() {
    local pasta="$1"
    local wp_dir="$pasta/wallpapers"
    # Tenta wallpaper.png/jpg/jpeg dentro da pasta wallpapers do tema
    for ext in png jpg jpeg webp; do
        [[ -f "$wp_dir/wallpaper.$ext" ]] && echo "$wp_dir/wallpaper.$ext" && return
    done
    # Qualquer imagem dentro de wallpapers/
    if [[ -d "$wp_dir" ]]; then
        find "$wp_dir" -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) | head -1
        return
    fi
    # Fallback: primeira imagem em qualquer lugar do tema
    find "$pasta" -maxdepth 3 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) \
        -not -path "*/.git/*" | head -1
}

# ── Gera o tema rofi ──────────────────────────────────────────────────────────

gerar_tema_rofi() {
cat > "$TEMA_ROFI" << 'RASI'
/* sweeper.rasi — Tema rofi do Sweeper */

* {
    bg0:        #0d0e11;
    bg1:        #13151a;
    bg2:        #1c1f27;
    bg3:        #252933;
    border-col: #2e3340;
    accent:     #7c6af7;
    accent-dim: #7c6af72e;
    fg0:        #e2e4ea;
    fg1:        #8b8fa8;
    fg2:        #3e4257;

    background-color: transparent;
    text-color:       @fg0;
    border:           0;
    margin:           0;
    padding:          0;
    spacing:          0;
}

window {
    background-color: @bg0;
    border:           1;
    border-color:     @border-col;
    border-radius:    14px;
    width:            760px;
    padding:          0;
}

mainbox {
    background-color: transparent;
    children:         [ inputbar, listview ];
    spacing:          0;
}

inputbar {
    background-color: @bg1;
    border-radius:    14px 14px 0 0;
    border:           0 0 1 0;
    border-color:     @border-col;
    padding:          14px 18px;
    spacing:          10px;
    children:         [ prompt, entry ];
}

prompt {
    background-color: @accent-dim;
    text-color:       @accent;
    border-radius:    6px;
    padding:          4px 10px;
    font:             "JetBrains Mono 10";
    vertical-align:   0.5;
}

entry {
    background-color: transparent;
    text-color:       @fg0;
    placeholder:      "buscar...";
    placeholder-color: @fg2;
    font:             "JetBrains Mono 11";
    vertical-align:   0.5;
}

listview {
    background-color: @bg1;
    border-radius:    0 0 14px 14px;
    padding:          14px;
    spacing:          8px;
    columns:          4;
    lines:            3;
    fixed-height:     true;
    scrollbar:        false;
}

element {
    background-color: @bg2;
    border-radius:    10px;
    orientation:      vertical;
    padding:          8px 6px 10px 6px;
    spacing:          6px;
    border:           1;
    border-color:     @border-col;
    cursor:           pointer;
}

element normal.normal {
    background-color: @bg2;
    border-color:     @border-col;
}

element selected.normal {
    background-color: @accent-dim;
    border-color:     @accent;
}

element alternate.normal {
    background-color: @bg2;
    border-color:     @border-col;
}

element-icon {
    background-color: @bg3;
    border-radius:    7px;
    size:             110px;
    horizontal-align: 0.5;
}

element-text {
    background-color: transparent;
    text-color:       @fg0;
    font:             "JetBrains Mono 10";
    horizontal-align: 0.5;
    vertical-align:   0.5;
}

element-text selected {
    text-color: @accent;
}
RASI
}



# ── Rofi base args ────────────────────────────────────────────────────────────

rofi_run() {
    rofi -dmenu \
         -i \
         -show-icons \
         -theme "$TEMA_ROFI" \
         "$@"
}

# Menu simples (sem grid de ícones)
rofi_simples() {
    rofi -dmenu \
         -i \
         -theme "$TEMA_ROFI" \
         -theme-str 'listview { columns: 1; lines: 3; }' \
         -theme-str 'element { orientation: horizontal; padding: 10px 14px; }' \
         -theme-str 'element-icon { size: 0px; }' \
         -theme-str 'window { width: 340px; }' \
         "$@"
}

# ── Menu Principal ────────────────────────────────────────────────────────────

menu_principal() {
    local tema_ativo wp_ativo prompt
    tema_ativo="$(ler_estado tema)"
    prompt="sweeper"
    [[ -n "$tema_ativo" ]] && prompt="sweeper · $tema_ativo"

    local escolha
    escolha=$(printf "󰔌  Temas\n󰹉  Wallpapers" \
        | rofi_simples -p "$prompt" -theme-str 'listview { lines: 2; }')

    case "$escolha" in
        *Temas)      menu_temas ;;
        *Wallpapers) menu_wallpapers ;;
    esac
}

# ── Menu de Temas ─────────────────────────────────────────────────────────────

menu_temas() {
    local tema_ativo
    tema_ativo="$(ler_estado tema)"

    local entradas=()

    while IFS= read -r -d '' pasta; do
        local nome
        nome="$(basename "$pasta")"
        deve_ignorar "$nome" && continue

        local preview label
        preview="$(achar_preview "$pasta")"
        label="$nome"
        [[ "$nome" == "$tema_ativo" ]] && label="${nome} ✓"

        if [[ -n "$preview" ]]; then
            entradas+=("${label}\0icon\x1f${preview}")
        else
            entradas+=("${label}")
        fi
    done < <(find "$DIR" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)

    [[ ${#entradas[@]} -eq 0 ]] && rofi_simples -p "erro" <<< "Nenhum tema encontrado" && return

    local escolha
    escolha=$( (echo -e "← Voltar"; printf "%b\n" "${entradas[@]}") | rofi_run -p "tema" -format p)
    [[ -z "$escolha" ]] && return

    [[ "$escolha" == *"Voltar"* ]] && menu_principal && return

    # Remove o marcador ✓ e espaços extras
    local tema_escolhido="${escolha% ✓}"

    aplicar_tema "$tema_escolhido"
}

# ── Menu de Wallpapers ────────────────────────────────────────────────────────

menu_wallpapers() {
    local wp_ativo
    wp_ativo="$(ler_estado wallpaper)"

    local entradas=()
    # Mapeia label → caminho real (para recuperar depois da escolha)
    declare -A mapa_caminhos
    # Rastreia caminhos reais para evitar duplicatas
    declare -A vistos

    # 1) Wallpapers dentro de cada pasta de tema (tema/wallpapers/*.png)
    while IFS= read -r -d '' pasta_tema; do
        local nome_tema
        nome_tema="$(basename "$pasta_tema")"
        deve_ignorar "$nome_tema" && continue

        local wp_dir="$pasta_tema/wallpapers"
        [[ ! -d "$wp_dir" ]] && continue

        while IFS= read -r -d '' img; do
            # Deduplicação por caminho real (resolve symlinks)
            local caminho_real
            caminho_real="$(realpath "$img" 2>/dev/null || echo "$img")"
            [[ -n "${vistos[$caminho_real]}" ]] && continue
            vistos["$caminho_real"]=1

            local nome_arquivo label
            nome_arquivo="$(basename "$img")"
            label="${nome_tema} · ${nome_arquivo}"
            [[ "$img" == "$wp_ativo" ]] && label="${label} ✓"

            entradas+=("${label}\0icon\x1f${caminho_real}")
            mapa_caminhos["$label"]="$caminho_real"
            mapa_caminhos["${nome_tema} · ${nome_arquivo}"]="$caminho_real"
        done < <(find "$wp_dir" -maxdepth 1 \
                    \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) \
                    -print0 | sort -z)

    done < <(find "$DIR" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)

    # 2) Wallpapers na pasta raiz wallpapers/ (ex: DIR/wallpapers/*.png)
    local wp_raiz="$DIR/wallpapers"
    if [[ -d "$wp_raiz" ]]; then
        while IFS= read -r -d '' img; do
            # Deduplicação por caminho real (resolve symlinks)
            local caminho_real
            caminho_real="$(realpath "$img" 2>/dev/null || echo "$img")"
            [[ -n "${vistos[$caminho_real]}" ]] && continue
            vistos["$caminho_real"]=1

            local nome_arquivo label
            nome_arquivo="$(basename "$img")"
            label="wallpapers · ${nome_arquivo}"
            [[ "$img" == "$wp_ativo" ]] && label="${label} ✓"

            entradas+=("${label}\0icon\x1f${caminho_real}")
            mapa_caminhos["$label"]="$caminho_real"
            mapa_caminhos["wallpapers · ${nome_arquivo}"]="$caminho_real"
        done < <(find "$wp_raiz" -maxdepth 1 \
                    \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) \
                    -print0 | sort -z)
    fi

    if [[ ${#entradas[@]} -eq 0 ]]; then
        rofi_simples -p "erro" <<< "Nenhum wallpaper encontrado"
        return
    fi

    local escolha
    escolha=$( (echo "← Voltar"; printf "%b\n" "${entradas[@]}") | rofi_run -p "wallpaper" -format p)
    [[ -z "$escolha" ]] && return

    # Remove ✓ do label para lookup no mapa
    local label_limpo="${escolha% ✓}"
    [[ "$escolha" == *"Voltar"* ]] && menu_principal && return
    local caminho="${mapa_caminhos[$label_limpo]}"

    if [[ -z "$caminho" || ! -f "$caminho" ]]; then
        rofi_simples -p "erro" <<< "Arquivo não encontrado: $escolha"
        return
    fi

    aplicar_wallpaper "$caminho"
}

# ── Ações ─────────────────────────────────────────────────────────────────────

aplicar_tema() {
    local nome="$1"

    if (cd "$DIR" && python "$SWEEPER" "$nome"); then
        salvar_estado "tema" "$nome"
        local wp_padrao
        wp_padrao="$(achar_preview "$DIR/$nome")"
        [[ -n "$wp_padrao" ]] && salvar_estado "wallpaper" "$wp_padrao"
        notify-send "Sweeper" "Wallpaper aplicado" --icon=image-x-generic 2>/dev/null || true
        menu_temas
    else
        rofi_simples -p "erro" <<< "Erro ao aplicar tema '$nome'"
    fi
}

aplicar_wallpaper() {
    local caminho="$1"
    local config_hyprpaper="$HOME/.config/hypr/hyprpaper.conf"

    # Atualiza o hyprpaper.conf (mesma lógica do sweeper.py)
    if [[ -f "$config_hyprpaper" ]]; then
        sed -i "s|^\s*path\s*=.*|    path = ${caminho}|" "$config_hyprpaper"
    fi

    # Aplica via hyprctl sem reiniciar o compositor
    hyprctl hyprpaper unload all            2>/dev/null
    hyprctl hyprpaper preload "$caminho"    2>/dev/null
    hyprctl hyprpaper wallpaper ",$caminho" 2>/dev/null

    # Reinicia hyprpaper para garantir aplicação
    pkill hyprpaper 2>/dev/null
    sleep 0.3
    hyprpaper &

    salvar_estado "wallpaper" "$caminho"
    notify-send "Sweeper" "Wallpaper aplicado" --icon=image-x-generic 2>/dev/null || true
    menu_wallpapers
}

# ── Boot ──────────────────────────────────────────────────────────────────────

# Gera o tema rofi se não existir ou se o script for mais novo que ele
if [[ ! -f "$TEMA_ROFI" || "$0" -nt "$TEMA_ROFI" ]]; then
    gerar_tema_rofi
fi

menu_principal
