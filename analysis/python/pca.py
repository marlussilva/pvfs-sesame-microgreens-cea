# -*- coding: utf-8 -*-
"""
PCA + Correlação (círculos legíveis) + LaTeX (correlação var × PCs)
- Winsorização por IQR (Regime × Ligth) quando necessário
- Biplot moderno (elipses 90%, setas finas/longas, rótulos repelidos, zoom suave)
- Correlograma pastel que não atrapalha os números (contorno preto reforçado)
- Tabela LaTeX com PC1–PC4 (|r|>=0.70 em negrito)

Saídas em: resultados_pca_cor/
"""

import os, re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from numpy.linalg import svd
from matplotlib.lines import Line2D
from matplotlib.colors import to_rgba
from matplotlib.patches import Circle
from scipy.stats import chi2
import matplotlib.patheffects as pe
import matplotlib as mpl

# -------------------- CONFIG --------------------
INPUT_XLSX_DEFAULT = "dados.xlsx"
POSSIBLE_WINS = ["resultados/dados_winsorizados.xlsx", "dados_winsorizados.xlsx"]
OUT_DIR = "resultados_pca_cor"
os.makedirs(OUT_DIR, exist_ok=True)

VARS_ORDER = [
    "HFW","LFW","HMD","LMD","FvFm","YII","NPQ","qP","ETR",
    "Chla","Chlb","Cart","TMD","EEMS","CTLA","CHL","Chla_Chlb"
]
TREAT_ORDER = [
    "Constant | White","Constant | RBW","Constant | Blue","Constant | Red",
    "Gauss | White","Gauss | RBW","Gauss | Blue","Gauss | Red"
]

YLABS_TEX = {
  "HFW": r"HFW (\textit{Hypocotyl Fresh Mass, g})",
  "LFW": r"LFW (\textit{Leaf Fresh Mass, g})",
  "HMD": r"HMD (\textit{Hypocotyl Dry Mass, g})",
  "LMD": r"LMD (\textit{Leaf Dry Mass, g})",
  "TMD": r"TMD (\textit{Total Dry Mass, g})",
  "FvFm": r"$F_v/F_m$ (\textit{Maximum Quantum Yield of PSII})",
  "YII": r"$Y(II)$ (\textit{Effective Quantum Yield of PSII})",
  "NPQ": r"NPQ (\textit{Non-Photochemical Quenching})",
  "qP": r"$q_P$ (\textit{Photochemical Quenching Coefficient})",
  "ETR": r"ETR (\textit{Electron Transport Rate})",
  "Chla": r"Chla (\textit{Chlorophyll a, }\textmu g g$^{-1}$ FW)",
  "Chlb": r"Chlb (\textit{Chlorophyll b, }\textmu g g$^{-1}$ FW)",
  "Cart": r"Cart (\textit{Carotenoids, }\textmu g g$^{-1}$ FW)",
  "CTLA": r"CTLA (\textit{Total Leaf Area, cm}$^{2}$)",  
  "CHL": r"CHL (\textit{Hypocotyl Length, cm})",
  "EEMS": r"EEMS (\textit{Energy Efficiency per Dry Matter, }$\mathrm{g}\,\mathrm{kWh}^{-1}$)",
  "Chla_Chlb": r"Chla\_Chlb (\textit{Chlorophyll a}/\textit{b} ratio)"
}

# -------------------- UTIL --------------------
def winsorize_iqr(s: pd.Series) -> pd.Series:
    v = s.dropna()
    if v.size < 4: return s
    q1, q3 = np.percentile(v, [25, 75])
    iqr = q3 - q1
    if iqr <= 0: return s
    lo, hi = q1 - 1.5*iqr, q3 + 1.5*iqr
    x = np.where(s < lo, lo, s)
    x = np.where(x > hi, hi, x)
    return pd.Series(x, index=s.index)

def lighten_rgb(color, amount=0.55):
    r, g, b, a = to_rgba(color)
    r = 1 - (1 - r) * (1 - amount)
    g = 1 - (1 - g) * (1 - amount)
    b = 1 - (1 - b) * (1 - amount)
    return (r, g, b, a)

def ellipse_points(x, y, conf=0.90, num=240):
    x, y = np.asarray(x), np.asarray(y)
    m = np.isfinite(x) & np.isfinite(y)
    x, y = x[m], y[m]
    if x.size < 3: return np.array([]), np.array([])
    cov = np.cov(x, y)
    vals, vecs = np.linalg.eigh(cov)
    order = vals.argsort()[::-1]
    vals, vecs = vals[order], vecs[:, order]
    theta = np.arctan2(*vecs[:,0][::-1])
    t = np.linspace(0, 2*np.pi, num)
    r = np.sqrt(chi2.ppf(conf, 2))
    a, b = r*np.sqrt(vals[0]), r*np.sqrt(vals[1])
    ex, ey = a*np.cos(t), b*np.sin(t)
    R = np.array([[np.cos(theta), -np.sin(theta)],[np.sin(theta), np.cos(theta)]])
    rot = R @ np.vstack([ex, ey])
    mx, my = np.mean(x), np.mean(y)
    return rot[0]+mx, rot[1]+my

def repel_positions(end_xy, base_radius=1.16, dtheta=np.deg2rad(8), r_step=0.06):
    N = end_xy.shape[0]
    ang = np.arctan2(end_xy[:,1], end_xy[:,0])
    rad = np.linalg.norm(end_xy, axis=1)
    order = np.argsort(ang)
    ang_sorted, rad_sorted = ang[order], rad[order]
    ang_off = np.zeros(N)
    rad_mul = np.ones(N)*base_radius
    min_sep = np.deg2rad(10)
    for i in range(1, N):
        j = order[i]
        if (abs(ang_sorted[i]-ang_sorted[i-1]) < min_sep and
            abs(rad_sorted[i]-rad_sorted[i-1]) < 0.30*np.nanmax(rad_sorted)):
            sign = -1 if (i % 2 == 0) else 1
            ang_off[j] += sign*dtheta
            rad_mul[j] += r_step*(1 + (i % 3))
    return rad_mul, ang_off

def load_data():
    for p in POSSIBLE_WINS:
        if os.path.exists(p):
            df = pd.read_excel(p); src = os.path.basename(p); break
    else:
        df = pd.read_excel(INPUT_XLSX_DEFAULT); src = os.path.basename(INPUT_XLSX_DEFAULT)

    df.columns = [re.sub(r"\s+", " ", str(c).replace("\xa0"," ")).strip() for c in df.columns]
    for c in df.columns:
        if c not in ["Regime","Ligth"] and df[c].dtype == object:
            df[c] = pd.to_numeric(df[c].astype(str).str.replace(",", ".", regex=False), errors="coerce")

    if "Regime" in df.columns:
        df["Regime"] = df["Regime"].astype(str).str.replace("Gaussian","Gauss", regex=False)
    if "Ligth" in df.columns:
        df["Ligth"] = df["Ligth"].astype(str).map(lambda x: {"RED":"Red","red":"Red"}.get(x, x))

    if "Chla" in df.columns and "Chlb" in df.columns and "Chla_Chlb" not in df.columns:
        df["Chla_Chlb"] = pd.to_numeric(df["Chla"], errors="coerce") / pd.to_numeric(df["Chlb"], errors="coerce")

    if src == os.path.basename(INPUT_XLSX_DEFAULT) and {"Regime","Ligth"}.issubset(df.columns):
        for v in [c for c in VARS_ORDER if c in df.columns]:
            df[v] = df.groupby(["Regime","Ligth"], observed=False)[v].transform(winsorize_iqr)

    return df

# -------------------- PCA --------------------
def compute_pca(X: pd.DataFrame):
    Z = (X - X.mean(0)) / X.std(0, ddof=1)
    U, S, Vt = svd(Z, full_matrices=False)
    scores = U * S
    loadings = Vt.T
    eigvals = (S**2) / (len(Z) - 1)
    explained = eigvals / eigvals.sum()
    return Z, scores, loadings, eigvals, explained

def var_pc_correlations(Z: np.ndarray, scores: np.ndarray, var_names, n_pc=4):
    n_pc = min(n_pc, scores.shape[1])
    Rs = np.zeros((len(var_names), n_pc))
    for j in range(len(var_names)):
        for k in range(n_pc):
            r = np.corrcoef(Z[:, j], scores[:, k])[0, 1]
            Rs[j, k] = r
    return pd.DataFrame(Rs, index=var_names, columns=[f"PC{i+1}" for i in range(n_pc)])

# -------------------- PCA BIPLOT --------------------
def plot_pca_biplot(scores, loadings, explained, vars_present, meta, basepath):
    palette_vars = list(plt.cm.tab20.colors) + list(plt.cm.tab20b.colors) + list(plt.cm.tab20c.colors)
    var_colors = {v: palette_vars[i % len(palette_vars)] for i, v in enumerate(vars_present)}

    fig, ax = plt.subplots(figsize=(8.8, 10.0), dpi=170)
    ax.set_facecolor("white")
    for sp in ax.spines.values(): sp.set_color("black")
    ax.grid(True, linestyle=":", color="0.85", alpha=1.0, zorder=0)
    ax.axhline(0, color="0.3", lw=1, ls="--", zorder=1)
    ax.axvline(0, color="0.3", lw=1, ls="--", zorder=1)

    ell_xs, ell_ys = [], []
    scatters_info = []
    if meta is not None and "Treatment" in meta.columns:
        treatments = [t for t in TREAT_ORDER if t in meta["Treatment"].unique().tolist()]
        cmap_spec = plt.cm.get_cmap("Spectral", max(8, len(treatments)))
        cols_base = {t: cmap_spec(i) for i, t in enumerate(treatments)}

        for t in treatments:
            m = (meta["Treatment"] == t).values
            ex, ey = ellipse_points(scores[m,0], scores[m,1], conf=0.90, num=240)
            if ex.size:
                ax.fill(ex, ey, color=lighten_rgb(cols_base[t], 0.75), lw=0.0, alpha=0.20, zorder=1)
                ell_xs.append(ex); ell_ys.append(ey)

        for t in treatments:
            m = (meta["Treatment"] == t).values
            s = ax.scatter(scores[m,0], scores[m,1], s=26, marker="o",
                           facecolor=cols_base[t], edgecolor="black", linewidth=0.5,
                           alpha=0.95, label=t, zorder=3)
            scatters_info.append((t, s, cols_base[t]))

    max_abs = np.max(np.abs(scores[:, :2])); scale = (max_abs * 1.22) if np.isfinite(max_abs) and max_abs>0 else 3.4
    ends = np.column_stack([loadings[:,0]*scale, loadings[:,1]*scale])
    rad_mul, ang_off = repel_positions(ends, base_radius=1.16, dtheta=np.deg2rad(8), r_step=0.06)
    HEAD_W, HEAD_L, LW = 0.09, 0.12, 1.1
    label_positions = []
    for i, var in enumerate(vars_present):
        c = var_colors[var]; ex, ey = ends[i]
        ax.arrow(0, 0, ex, ey, head_width=HEAD_W, head_length=HEAD_L,
                 length_includes_head=True, linewidth=LW, color=c, alpha=0.95, zorder=5)
        ax.scatter([ex], [ey], s=18, facecolor=c, edgecolor="white", linewidth=0.6, zorder=6)
        ang = np.arctan2(ey, ex) + ang_off[i]; r = np.hypot(ex,ey) * rad_mul[i]
        lx, ly = r*np.cos(ang), r*np.sin(ang)
        label_positions.append((lx, ly))
        ax.plot([ex, lx], [ey, ly], color=c, alpha=0.6, linewidth=0.8, zorder=5)
        ax.text(lx, ly, var, fontsize=12, ha="center", va="center", color=c, zorder=7,
                path_effects=[pe.withStroke(linewidth=2.6, foreground="white")])

    items_x = [scores[:,0], ends[:,0], np.array(label_positions)[:,0]] + ell_xs
    items_y = [scores[:,1], ends[:,1], np.array(label_positions)[:,1]] + ell_ys
    all_x, all_y = np.concatenate(items_x), np.concatenate(items_y)
    pad_x = 0.05*(np.nanmax(all_x)-np.nanmin(all_x))
    pad_y = 0.07*(np.nanmax(all_y)-np.nanmin(all_y))
    ax.set_xlim(np.nanmin(all_x)-pad_x, np.nanmax(all_x)+pad_x)
    ax.set_ylim(np.nanmin(all_y)-pad_y, np.nanmax(all_y)+pad_y)

    ax.set_xlabel(f"Dim1 (PC1) – {explained[0]*100:.1f}%")
    ax.set_ylabel(f"Dim2 (PC2) – {explained[1]*100:.1f}%")
    ax.set_title("PCA – Biplot", loc="left", pad=6)

    handles_vars = [Line2D([0],[0], color={v: var_colors[v]}[v], lw=2) for v in vars_present]
    leg_vars = plt.legend(handles_vars, vars_present, title="Variables",
                          loc="upper left", bbox_to_anchor=(1.02, 0.98),
                          ncol=1, frameon=False, fontsize=9, title_fontsize=10)
    plt.gca().add_artist(leg_vars)
    if scatters_info:
        handles_treat = [Line2D([0],[0], marker='o', linestyle='None',
                                markerfacecolor=col, markeredgecolor='black',
                                markeredgewidth=0.6, markersize=7)
                         for _,_,col in scatters_info]
        labels_treat  = [t for t,_,_ in scatters_info]
        plt.legend(handles_treat, labels_treat, title="Treatments",
                   loc="upper left", bbox_to_anchor=(1.02, 0.40),
                   ncol=1, frameon=False, fontsize=9, title_fontsize=10)

    fig = plt.gcf()
    fig.subplots_adjust(left=0.08, right=0.84, top=0.99, bottom=0.12)

    png = os.path.join(basepath, "pca_biplot_zoom.png")
    pdf = os.path.join(basepath, "pca_biplot_zoom.pdf")
    fig.savefig(png, dpi=300, bbox_inches="tight", pad_inches=0.06)
    fig.savefig(pdf, dpi=300, bbox_inches="tight", pad_inches=0.06)
    plt.close(fig)
    return png, pdf

# -------------------- Correlação (círculos legíveis) --------------------
def plot_correlation_circles_legible(X: pd.DataFrame, basepath: str):
    R = X.corr().astype(float)
    labels = list(R.columns)
    n = len(labels)

    fig = plt.figure(figsize=(1.0 + 0.68*n, 1.2 + 0.68*n), dpi=170)
    ax = fig.add_subplot(111)
    ax.set_aspect('equal')
    ax.set_xlim(-0.5, n-0.5); ax.set_ylim(-0.5, n-0.5)
    ax.invert_yaxis()

    for spine in ax.spines.values():
        spine.set_visible(True); spine.set_linewidth(1.4); spine.set_color("black")
    ax.tick_params(axis='both', colors='black', width=1.2, labelsize=10)

    base_cmap = mpl.cm.get_cmap("RdBu_r")

    def pastel(c, amt=0.60):
        r,g,b,a = mpl.colors.to_rgba(c)
        r = 1 - (1 - r) * (1 - amt)
        g = 1 - (1 - g) * (1 - amt)
        b = 1 - (1 - b) * (1 - amt)
        return (r,g,b,a)

    rmax = 0.46
    for i in range(n):
        for j in range(n):
            if i <= j:
                continue
            r = R.iloc[i, j]
            color = pastel(base_cmap(0.5*(r+1.0)), 0.60)
            radius = rmax * abs(r)
            circ = Circle((j, i), radius=radius, facecolor=color,
                          edgecolor="black", lw=1.2, zorder=2)
            ax.add_patch(circ)
            ax.text(j, i, f"{r:.2f}", va='center', ha='center', fontsize=10.5, color="black",
                    zorder=3,
                    path_effects=[
                        pe.withStroke(linewidth=3.0, foreground="white"),
                        pe.withStroke(linewidth=0.8, foreground="black", alpha=0.30)
                    ])

    for d in range(n):
        ax.text(d, d, "1.00", va='center', ha='center', fontsize=10.5, color="black",
                path_effects=[pe.withStroke(linewidth=2.6, foreground="white")])

    ax.set_xticks(range(n)); ax.set_xticklabels(labels, rotation=60, ha='right', fontsize=10, color="black")
    ax.set_yticks(range(n)); ax.set_yticklabels(labels, fontsize=10, color="black")

    # --- barra de cores centralizada sob o eixo principal (ax) ---
    # Ajuste o espaçamento do gráfico para comportar a barra com folga
    fig.subplots_adjust(left=0.16, right=0.98, top=0.98, bottom=0.18)

    bbox = ax.get_position()      # posição do eixo em coords da figura
    cbar_h = 0.035                # altura da barra
    cbar_pad = 0.0650              # distância vertical entre o eixo e a barra
    # x, y, width, height
    cax = fig.add_axes([bbox.x0, bbox.y0 - cbar_pad - cbar_h, bbox.width, cbar_h])

    norm = mpl.colors.Normalize(vmin=-1, vmax=1)
    cb = mpl.colorbar.ColorbarBase(cax, cmap=base_cmap, norm=norm, orientation='horizontal')
    cb.outline.set_linewidth(1.4); cb.outline.set_edgecolor('black')
    cb.ax.tick_params(colors='black', width=1.2)
    cb.set_label("Pearson correlation (r)", color='black')

    png = os.path.join(basepath, "correlacao_circulos_legivel_en.png")
    pdf = os.path.join(basepath, "correlacao_circulos_legivel_en.pdf")
    fig.savefig(png, dpi=300, bbox_inches="tight", pad_inches=0.05)
    fig.savefig(pdf, dpi=300, bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    return png, pdf, R

# -------------------- LaTeX --------------------
def latex_table_pca_corr(Rvar_PC: pd.DataFrame, eigvals: np.ndarray, explained: np.ndarray,
                         vars_present: list, out_tex_path: str):
    rows = [v for v in VARS_ORDER if v in vars_present]
    R = Rvar_PC.loc[rows].copy()
    k = R.shape[1]
    lines = []
    lines.append(r"\begin{table}[H]")
    lines.append(r"\centering")
    lines.append(r"\caption{Coeficientes de correlação (\textit{r}) entre variáveis e os quatro primeiros componentes principais (PC1--PC4). Valores em \textbf{negrito} indicam correlação forte ($|r| \geq 0.70$).}")
    lines.append(r"\begin{tabular}{l" + "c"*k + r"}")
    lines.append(r"\hline")
    header = r"\textbf{Variável (nome completo)} & " + " & ".join([fr"\textbf{{PC{i}}}" for i in range(1,k+1)]) + r" \\"
    lines.append(header)
    lines.append(r"\hline")
    for v in rows:
        name = YLABS_TEX.get(v, v)
        vals = []
        for pc in range(k):
            val = float(R.loc[v, f"PC{pc+1}"])
            s = f"{val:.2f}"
            if abs(val) >= 0.70:
                s = r"\textbf{" + s + r"}"
            vals.append(s)
        lines.append(f"{name} & " + " & ".join(vals) + r" \\")
    lines.append(r"\hline")
    kall = min(4, len(eigvals))
    eigs = " & ".join([f"{eigvals[i]:.3f}" for i in range(kall)])
    vars_pct = " & ".join([f"{explained[i]*100:.2f}" for i in range(kall)])
    cum = np.cumsum(explained)[:kall]*100
    cum_s = " & ".join([f"{c:.2f}" for c in cum])
    lines.append(r"\textbf{Eigenvalue} & " + eigs + r" \\")
    lines.append(r"\textbf{Variance (\%)} & " + vars_pct + r" \\")
    lines.append(r"\textbf{Cumulative (\%)} & " + cum_s + r" \\")
    lines.append(r"\hline")
    lines.append(r"\end{tabular}")
    lines.append(r"\label{tab:PCA_correlacoes}")
    lines.append(r"\end{table}")

    with open(out_tex_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    return out_tex_path

# -------------------- MAIN --------------------
def main():
    df = load_data()
    vars_present = [v for v in VARS_ORDER if v in df.columns]
    X = df[vars_present].dropna(axis=0, how="any")
    if X.empty:
        raise SystemExit("Sem dados completos (todas as variáveis) para PCA/correlação.")

    meta = None
    if {"Regime","Ligth"}.issubset(df.columns):
        meta = df.loc[X.index, ["Regime","Ligth"]].astype(str).copy()
        meta["Treatment"] = meta["Regime"] + " | " + meta["Ligth"]

    Z, scores, loadings, eigvals, explained = compute_pca(X)

    plot_pca_biplot(scores, loadings, explained, vars_present, meta, OUT_DIR)

    _, _, R = plot_correlation_circles_legible(X, OUT_DIR)

    Rvar_PC = var_pc_correlations(Z.values, scores, vars_present, n_pc=min(4, scores.shape[1]))

    tex_path = os.path.join(OUT_DIR, "pca_correlacoes.tex")
    latex_table_pca_corr(Rvar_PC, eigvals, explained, vars_present, tex_path)

    print("Arquivos gerados em:", os.path.abspath(OUT_DIR))
    print(" - pca_biplot_zoom.png / .pdf")
    print(" - correlacao_circulos_legivel_en.png / .pdf")
    print(" - pca_correlacoes.tex")

if __name__ == "__main__":
    main()
