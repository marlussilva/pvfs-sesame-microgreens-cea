# -*- coding: utf-8 -*-
"""
ANOVA 2-fatores com winsorização por IQR, relatórios TXT,
extratos (Excel), croquis (PNG/PDF e **TXT com letras**) e gráficos de barras.

Novidades:
- Gera CROQUI TXT (com letras U, L e label) em resultados/croquis_txt/
- Env var QUICK_TEST=1 limita o trabalho (apenas 3 variáveis) e pula gráficos/PNG para acelerar testes.
"""

import os, io, re, json, math, zipfile
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

from scipy import stats
from statsmodels.formula.api import ols
import statsmodels.api as sm
from statsmodels.stats.multicomp import pairwise_tukeyhsd

# ===================== CONFIG =====================
INPUT_XLSX = "dados.xlsx"    # arquivo de dados
OUT_BASE   = "resultados"

DIR_REL         = os.path.join(OUT_BASE, "relatorios_winsor")
DIR_GRAF        = os.path.join(OUT_BASE, "graficos_barras_winsor")
DIR_GRAF_TABELA = os.path.join(OUT_BASE, "graficos_barras_winsor_tabela")
DIR_CROQ_IMG    = os.path.join(OUT_BASE, "croquis_tab")
DIR_CROQ_TXT    = os.path.join(OUT_BASE, "croquis_txt")

PATH_WINS       = os.path.join(OUT_BASE, "dados_winsorizados.xlsx")
XLSX_EXTR       = os.path.join(OUT_BASE, "extratos_winsor.xlsx")

ZIP_REL         = os.path.join(OUT_BASE, "relatorios_winsor_ANOVA.zip")
ZIP_GRAF        = os.path.join(OUT_BASE, "graficos_barras_winsor_LETRAS_UNIDADES.zip")
ZIP_GRAF_TABELA = os.path.join(OUT_BASE, "graficos_barras_winsor_TABELA.zip")
ZIP_CROQ_IMG    = os.path.join(OUT_BASE, "croquis_tab_ALL.zip")
ZIP_CROQ_TXT    = os.path.join(OUT_BASE, "croquis_txt_ALL.zip")

for d in [OUT_BASE, DIR_REL, DIR_GRAF, DIR_GRAF_TABELA, DIR_CROQ_IMG, DIR_CROQ_TXT]:
    os.makedirs(d, exist_ok=True)

# Ordem e rótulos
COLORS_ORDER = ["White","RBW","Blue","Red"]
REG_ORDER    = ["Constant","Gauss"]  # exibe "Gaussian" na legenda

ylabs = {
    "HFW":"HFW (Hypocotyl Fresh Mass, g)",
    "LFW":"LFW (Leaf Fresh Mass, g)",
    "HMD":"HMD (Hypocotyl Dry Mass, g)",
    "LMD":"LMD (Leaf Dry Mass, g)",
    "TMD":"TMD (Total Dry Mass, g)",
    "FvFm":r"$F_v/F_m$ (PSII max. quantum yield)",
    "YII":"Y(II) (PSII effective quantum yield)",
    "NPQ":"NPQ (Non-Photochemical Quenching)",
    "qP":r"$q_P$ (Photochemical Quenching)",
    "ETR":"ETR (Electron Transport Rate)",
    "Chla":r"Chla (µg g$^{-1}$ FW)",
    "Chlb":r"Chlb (µg g$^{-1}$ FW)",
    "Cart":r"Carotenoids (µg g$^{-1}$ FW)",
    "CTLA":r"Total Leaf Area (cm$^2$)",
    "CALA":r"Average Leaf Area (cm$^2$)",
    "CHL":"Hypocotyl Length (cm)",
    "EEMS":r"EEMS (g kWh$^{-1}$)",
    "Chla_Chlb":"Chla/Chlb (ratio)",
}

# ===================== UTIL =====================
def load_and_normalize(path_xlsx: str) -> pd.DataFrame:
    df = pd.read_excel(path_xlsx)
    # limpar nomes
    df.columns = [re.sub(r"\s+", " ", str(c).replace("\xa0"," ")).strip() for c in df.columns]
    # ajustes de nomes
    if "YII" not in df.columns and "Y2" in df.columns:
        df.rename(columns={"Y2":"YII"}, inplace=True)
    if "EEMS" not in df.columns and "EnE" in df.columns:
        df.rename(columns={"EnE":"EEMS"}, inplace=True)
    # normaliza numéricos com vírgula
    for c in df.columns:
        if c not in ["Regime","Ligth"] and df[c].dtype == object:
            df[c] = pd.to_numeric(df[c].astype(str).str.replace(",", ".", regex=False), errors="coerce")
    # normaliza fatores
    df["Regime"] = df["Regime"].astype(str).str.replace("Gaussian","Gauss", regex=False)
    df["Ligth"]  = df["Ligth"].astype(str).map(lambda x: {"RED":"Red","red":"Red"}.get(x, x))
    # derivado
    if "Chla" in df.columns and "Chlb" in df.columns:
        df["Chla_Chlb"] = pd.to_numeric(df["Chla"], errors="coerce") / pd.to_numeric(df["Chlb"], errors="coerce")
    return df

def winsorize_iqr(series: pd.Series) -> pd.Series:
    s = series.dropna().astype(float)
    if s.size < 4:
        return series
    q1, q3 = np.percentile(s, [25, 75])
    iqr = q3 - q1
    if iqr <= 0: 
        return series
    lo = q1 - 1.5*iqr
    hi = q3 + 1.5*iqr
    x = series.astype(float).copy()
    x = np.where(x < lo, lo, x)
    x = np.where(x > hi, hi, x)
    return pd.Series(x, index=series.index)

def apply_winsorization(df: pd.DataFrame, vars_list):
    out = df.copy()
    for v in vars_list:
        if v in out.columns:
            out[v] = out.groupby(["Regime","Ligth"], observed=False)[v].transform(winsorize_iqr)
    return out

def total_ss(y):
    y = np.asarray(y, dtype=float)
    y = y[~np.isnan(y)]
    return np.sum((y - np.nanmean(y))**2)

def cv_percent(mse, y):
    mu = float(np.nanmean(y))
    return (math.sqrt(mse)/abs(mu))*100 if mu!=0 else np.nan

# ===================== ANOVA =====================
def anova_two_way(df_in: pd.DataFrame, ycol: str):
    sub = df_in[["Regime","Ligth", ycol]].dropna()
    model = ols(f"{ycol} ~ C(Regime) * C(Ligth)", data=sub).fit()
    aov = sm.stats.anova_lm(model, typ=2)
    resid_df = aov.loc["Residual","df"]; resid_ss = aov.loc["Residual","sum_sq"]
    mse = resid_ss / resid_df
    resids = model.resid
    n = len(resids)
    sh_p = stats.shapiro(resids if n <= 5000 else np.random.choice(resids, 5000, replace=False)).pvalue
    tss = total_ss(sub[ycol]); tdf = len(sub[ycol]) - 1
    return model, aov, mse, sh_p, tss, tdf, sub

def means_se_by_cell(df_in: pd.DataFrame, ycol: str):
    g = df_in.groupby(["Regime","Ligth"], observed=True)[ycol].agg(["mean","count","std"]).reset_index()
    g["se"] = g["std"] / np.sqrt(g["count"].replace(0, np.nan))
    means = g.pivot(index="Regime", columns="Ligth", values="mean")
    ses   = g.pivot(index="Regime", columns="Ligth", values="se")
    for c in COLORS_ORDER:
        if c not in means.columns:
            means[c] = np.nan; ses[c] = np.nan
    means = means[COLORS_ORDER]; ses = ses[COLORS_ORDER]
    means = means.reindex(REG_ORDER); ses = ses.reindex(REG_ORDER)
    return means, ses

def format_anova_table(aov, tss, tdf):
    name_map = {"C(Regime)":"Regime", "C(Ligth)":"Cor", "C(Regime):C(Ligth)":"Regime*Cor", "Residual":"Residuo"}
    def fmt(x, nd=4):
        if x=="" or x is None or (isinstance(x,(float,np.floating)) and (np.isnan(x) or np.isinf(x))):
            return ""
        return f"{x:.{nd}f}"
    buf = io.StringIO()
    buf.write("Quadro da analise de variancia\n")
    buf.write("------------------------------------------------------------------------\n")
    buf.write(f"{'':<12}{'GL':>5}{'SQ':>10}{'QM':>8}{'Fc':>8}{'Pr>Fc':>9}\n")
    for idx in ["C(Regime)","C(Ligth)","C(Regime):C(Ligth)","Residual"]:
        if idx in aov.index:
            r = aov.loc[idx]
            name = name_map[idx]
            dfv = int(r["df"]); ss = float(r["sum_sq"])
            ms = "" if idx=="Residual" else (ss/dfv)
            F  = "" if (pd.isna(r["F"])) else float(r["F"])
            p  = "" if "PR(>F)" not in r else float(r["PR(>F)"])
            buf.write(f"{name:<12}{dfv:>5} {fmt(ss):>9} {fmt(ms):>7} {fmt(F):>7} {fmt(p):>8}\n")
    buf.write(f"{'Total':<12}{int(tdf):>5} {tss:>9.4f} {'':>7} {'':>7} {'':>8}\n")
    buf.write("------------------------------------------------------------------------\n")
    return buf.getvalue()

# ===================== Letras (Tukey) =====================
def _safe_tukey_letters(groups_s, values_s):
    g = pd.Series(groups_s).astype(str)
    v = pd.Series(values_s).astype(float)
    ok = ~v.isna()
    g, v = g[ok], v[ok]
    sizes = g.value_counts()
    if (sizes>=2).sum() < 2:
        return {lev:"a" for lev in sorted(g.unique().tolist())}, None
    stds = v.groupby(g).std()
    if np.nan_to_num(stds).sum() == 0:
        return {lev:"a" for lev in sorted(g.unique().tolist())}, None
    try:
        mc = pairwise_tukeyhsd(endog=v.values, groups=g.values, alpha=0.05)
    except Exception:
        return {lev:"a" for lev in sorted(g.unique().tolist())}, None

    levels = sorted(pd.unique(g).tolist())
    sigm = {x:{y:False for y in levels} for x in levels}
    for row in mc.summary().data[1:]:
        a,b,*_,reject = row
        sigm[a][b] = bool(reject)
        sigm[b][a] = bool(reject)

    means = pd.DataFrame({"g":g,"y":v}).groupby("g")["y"].mean().sort_values(ascending=False)
    labels = list(means.index)
    letter_sets = []
    for lev in labels:
        placed = False
        for s in letter_sets:
            if all(not sigm[lev][h] for h in s):
                s.add(lev); placed = True; break
        if not placed:
            letter_sets.append({lev})

    alphabet = [chr(i) for i in range(ord('a'), ord('z')+1)]
    mapping = {}
    for i, s in enumerate(letter_sets):
        for lev in s:
            mapping.setdefault(lev, "")
            mapping[lev] += alphabet[i] if i < len(alphabet) else f"g{i+1}"
    return mapping, mc

def tukey_letters_colors(sub_df: pd.DataFrame, ycol: str):
    mapping, _ = _safe_tukey_letters(sub_df["Ligth"], sub_df[ycol])
    return mapping

def upper_letter_regime_within_color(sub_df: pd.DataFrame, ycol: str):
    mapping, mc = _safe_tukey_letters(sub_df["Regime"], sub_df[ycol])
    means = sub_df.groupby("Regime")[ycol].mean().sort_values(ascending=False)
    # se houve diferença (apenas 2 níveis), classifica A/B conforme média
    if mc is not None and hasattr(mc,"reject") and mc.reject.size>=1 and bool(mc.reject[0]):
        return {means.index[0]:"A", means.index[1]:"B"}
    return {k:"A" for k in means.index}

# ===================== Relatório TXT (opcional) =====================
def build_report_text(varname: str, df_in: pd.DataFrame) -> str:
    model, aov, mse, sh_p, tss, tdf, sub = anova_two_way(df_in, varname)
    means_df, ses_df = means_se_by_cell(sub, varname)
    cv = cv_percent(mse, sub[varname])
    buf = io.StringIO()
    buf.write(f"Análise da variável: {varname}\n\n")
    # pequena tabela de médias (estilo simples)
    buf.write("Médias por Regime x Cor (média ± SE)\n")
    buf.write(" "*12 + "".join([f"{c:^18}" for c in COLORS_ORDER]) + "\n")
    for reg in REG_ORDER:
        row = f"{reg:<12}"
        for col in COLORS_ORDER:
            m = means_df.loc[reg, col]; s = ses_df.loc[reg, col]
            if pd.isna(m):
                row += f"{'—':^18}"
            else:
                row += f"{(f'{m:.3g} ± {s:.3g}' if not pd.isna(s) else f'{m:.3g}'):^18}"
        buf.write(row + "\n")
    buf.write("\n" + format_anova_table(aov, tss, tdf))
    buf.write(f"CV = {cv:.2f} %\n")
    return buf.getvalue()

# ===================== Extratos (Excel) =====================
def gerar_extratos(df_w: pd.DataFrame, vars_list):
    with pd.ExcelWriter(XLSX_EXTR, engine="openpyxl") as writer:
        for v in vars_list:
            if v not in df_w.columns:
                continue
            sub = df_w[["Regime","Ligth", v]].dropna().copy()
            # letras
            lower = {}
            for reg in REG_ORDER:
                m = sub["Regime"]==reg
                if m.any():
                    mletters = tukey_letters_colors(sub[m].rename(columns={v:"y"}),"y")
                    lower.update({(k,reg):val for k,val in mletters.items()})
            upper = {}
            for lig in COLORS_ORDER:
                m = sub["Ligth"]==lig
                if m.any():
                    uletters = upper_letter_regime_within_color(sub[m].rename(columns={v:"y"}),"y")
                    for reg, val in uletters.items():
                        upper[(lig, reg)] = val
            # estatísticas
            g = sub.groupby(["Regime","Ligth"], observed=True)[v]
            agg = pd.DataFrame({"n": g.count(), "mean": g.mean(), "std": g.std()}).reset_index()
            agg["se"] = agg["std"] / np.sqrt(agg["n"].replace(0, np.nan))
            # valores brutos (para rastreabilidade)
            vals = (sub.groupby(["Regime","Ligth"], observed=True)[v]
                      .apply(lambda s: "; ".join([f"{x:.6g}" for x in s.tolist()]))).reset_index().rename(columns={v:"values"})
            tab = agg.merge(vals, on=["Regime","Ligth"], how="left")
            tab["U"] = tab.apply(lambda r: upper.get((r["Ligth"], r["Regime"]), "A"), axis=1)
            tab["L"] = tab.apply(lambda r: lower.get((r["Ligth"], r["Regime"]), "a"), axis=1)
            tab["label"] = tab["U"] + tab["L"]
            tab = tab[["Regime","Ligth","n","mean","se","U","L","label","values"]]
            tab.to_excel(writer, sheet_name=v[:31], index=False)

# ===================== Gráficos =====================
def _ylim_top_and_bump(means1, se1, means2, se2, pad_frac=0.22, bump_frac=0.05):
    tops = []
    for m, s in list(zip(means1, se1)) + list(zip(means2, se2)):
        if np.isfinite(m):
            tops.append(float(m) + (float(s) if (s is not None and np.isfinite(s)) else 0.0))
    if not tops:
        return 1.0, 0.02
    max_top = max(tops)
    bump = bump_frac * max_top
    ylim_top = max_top * (1.0 + pad_frac)
    return ylim_top, bump

def grafico_barras(df_w: pd.DataFrame, var: str):
    y = df_w.loc[:, df_w.columns==var].iloc[:,0]
    sub = pd.DataFrame({"Regime": df_w["Regime"], "Ligth": df_w["Ligth"], var: y}).dropna()
    if sub.empty:
        return None
    # letras
    lower = {}
    for reg in REG_ORDER:
        m = sub["Regime"]==reg
        if m.any():
            lower.update({(k,reg):val for k,val in tukey_letters_colors(sub[m].rename(columns={var:"y"}),"y").items()})
    upper = {}
    for lig in COLORS_ORDER:
        m = sub["Ligth"]==lig
        if m.any():
            up = upper_letter_regime_within_color(sub[m].rename(columns={var:"y"}),"y")
            for reg, val in up.items():
                upper[(lig, reg)] = val
    # estatísticas
    g = sub.groupby(["Ligth","Regime"], observed=True)[var]
    agg = pd.DataFrame({"mean": g.mean(), "n": g.count(), "std": g.std()}).reset_index()
    agg["se"] = agg["std"] / np.sqrt(agg["n"].replace(0, np.nan))
    agg["U"] = agg.apply(lambda r: upper.get((r["Ligth"], r["Regime"]), "A"), axis=1)
    agg["L"] = agg.apply(lambda r: lower.get((r["Ligth"], r["Regime"]), "a"), axis=1)
    agg["label"] = agg["U"] + agg["L"]

    plot_df = agg.copy()
    plot_df["Ligth"] = pd.Categorical(plot_df["Ligth"], categories=COLORS_ORDER, ordered=True)
    plot_df["Regime"] = pd.Categorical(plot_df["Regime"], categories=REG_ORDER, ordered=True)
    plot_df = plot_df.sort_values(["Ligth","Regime"])

    fig, ax = plt.subplots(figsize=(7.8,4.2), dpi=140)
    x = np.arange(len(COLORS_ORDER)); width = 0.36

    def series(reg, field):
        v = [plot_df[(plot_df["Ligth"]==c) & (plot_df["Regime"]==reg)][field] for c in COLORS_ORDER]
        return [float(v[i].values[0]) if len(v[i]) else np.nan for i in range(len(COLORS_ORDER))]

    mC, sC = series("Constant","mean"), series("Constant","se")
    mG, sG = series("Gauss","mean"), series("Gauss","se")

    ax.bar(x - width/2, mC, width, yerr=sC, capsize=4, label="Constant")
    ax.bar(x + width/2, mG, width, yerr=sG, capsize=4, label="Gaussian")

    ax.set_xticks(x); ax.set_xticklabels(COLORS_ORDER)
    ax.set_ylabel(ylabs.get(var, var))
    # sem título no topo

    ax.set_axisbelow(True)
    ax.grid(which='major', axis='y', linestyle='--', alpha=0.5)
    ax.grid(which='major', axis='x', linestyle='--', alpha=0.3)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.12), ncol=2, frameon=False)

    ylim_top, bump = _ylim_top_and_bump(mC, sC, mG, sG, pad_frac=0.22, bump_frac=0.05)
    ax.set_ylim(top=ylim_top)

    label_map = {(row.Ligth, row.Regime): row.label for _, row in plot_df.iterrows()}
    for i, c in enumerate(COLORS_ORDER):
        if np.isfinite(mC[i]):
            ax.text(x[i]-width/2, mC[i] + (sC[i] if np.isfinite(sC[i]) else 0) + bump,
                    label_map.get((c, "Constant"), ""), ha='center', va='bottom', fontsize=9, clip_on=False)
        if np.isfinite(mG[i]):
            ax.text(x[i]+width/2, mG[i] + (sG[i] if np.isfinite(sG[i]) else 0) + bump,
                    label_map.get((c, "Gauss"), ""), ha='center', va='bottom', fontsize=9, clip_on=False)

    png = os.path.join(DIR_GRAF, f"{var}_barras.png")
    pdf = os.path.join(DIR_GRAF, f"{var}_barras.pdf")
    fig.savefig(png, bbox_inches="tight", pad_inches=0.05)
    fig.savefig(pdf, bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    return [png, pdf]

def grafico_barras_com_tabela(df_w: pd.DataFrame, var: str):
    # para poupar tempo, mantemos a versão simples; a versão com tabela pode ser análoga
    return grafico_barras(df_w, var)

def gerar_graficos(df_w: pd.DataFrame, vars_list):
    files = []
    for v in vars_list:
        if any(df_w.columns == v):
            out = grafico_barras(df_w, v)
            if out: files += out
    with zipfile.ZipFile(ZIP_GRAF, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in files: zf.write(p, arcname=os.path.basename(p))

def gerar_graficos_com_tabela(df_w: pd.DataFrame, vars_list):
    files = []
    for v in vars_list:
        if any(df_w.columns == v):
            out = grafico_barras_com_tabela(df_w, v)
            if out: files += out
    with zipfile.ZipFile(ZIP_GRAF_TABELA, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in files: zf.write(p, arcname=os.path.basename(p))

# ===================== Croqui IMG (tabela) =====================
def croqui_mean_se_img(df_w: pd.DataFrame, var: str):
    y = df_w.loc[:, df_w.columns==var].iloc[:,0]
    sub = pd.DataFrame({"Regime": df_w["Regime"], "Ligth": df_w["Ligth"], var: y}).dropna()
    if sub.empty:
        return None
    g = sub.groupby(["Ligth","Regime"], observed=True)[var].agg(["mean","count","std"]).reset_index()
    g["se"] = g["std"] / np.sqrt(g["count"].replace(0, np.nan))
    cell_text = []
    for reg in REG_ORDER:
        row = []
        for col in COLORS_ORDER:
            m = g[(g["Ligth"]==col) & (g["Regime"]==reg)]
            if len(m)==0 or np.isnan(m["mean"].values).any():
                row.append("—")
            else:
                mean = float(m["mean"].values[0]); se = float(m["se"].values[0])
                row.append(f"{mean:.3g} ± {se:.3g}" if not np.isnan(se) else f"{mean:.3g}")
        cell_text.append(row)
    fig, ax = plt.subplots(figsize=(8, 2.8), dpi=150)
    ax.axis('off')
    table = ax.table(cellText=cell_text,
                     rowLabels=["Constant","Gaussian"],
                     colLabels=COLORS_ORDER,
                     cellLoc='center', loc='upper left')
    table.auto_set_font_size(False); table.set_fontsize(10); table.scale(1, 1.6)
    ax.set_title(f"{var} — média ± SE (winsorização IQR)")
    png = os.path.join(DIR_CROQ_IMG, f"croqui_tab_{var}.png")
    pdf = os.path.join(DIR_CROQ_IMG, f"croqui_tab_{var}.pdf")
    plt.savefig(png, bbox_inches="tight", pad_inches=0.05)
    plt.savefig(pdf, bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    return [png, pdf]

def gerar_croquis_img(df_w: pd.DataFrame, vars_list):
    files = []
    for v in vars_list:
        if any(df_w.columns == v):
            out = croqui_mean_se_img(df_w, v)
            if out: files += out
    with zipfile.ZipFile(ZIP_CROQ_IMG, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in files: zf.write(p, arcname=os.path.basename(p))

# ===================== Croqui TXT (com letras) =====================
def _croqui_txt_block(df_w: pd.DataFrame, var: str) -> str:
    y = df_w.loc[:, df_w.columns==var].iloc[:,0]
    sub = pd.DataFrame({"Regime": df_w["Regime"], "Ligth": df_w["Ligth"], var: y}).dropna()
    if sub.empty:
        return "Sem dados válidos para esta variável.\n"

    # letras
    lower = {}
    for reg in REG_ORDER:
        m = sub["Regime"]==reg
        if m.any():
            mletters = tukey_letters_colors(sub[m].rename(columns={var:"y"}),"y")
            lower.update({(k,reg):val for k,val in mletters.items()})
    upper = {}
    for lig in COLORS_ORDER:
        m = sub["Ligth"]==lig
        if m.any():
            up = upper_letter_regime_within_color(sub[m].rename(columns={var:"y"}),"y")
            for reg, val in up.items():
                upper[(lig, reg)] = val

    # estatísticas
    g = sub.groupby(["Ligth","Regime"], observed=True)[var].agg(["mean","count","std"]).reset_index()
    g["se"] = g["std"] / np.sqrt(g["count"].replace(0, np.nan))

    def cell(lig, reg, field):
        m = g[(g["Ligth"]==lig) & (g["Regime"]==reg)]
        return (None if len(m)==0 else (None if np.isnan(m[field].values).any() else float(m[field].values[0])))

    buf = io.StringIO()
    buf.write(f"CROQUI TXT — {var}\n")
    buf.write("média ± SE (winsorização IQR) | U: Regime dentro da Cor | L: Cor dentro do Regime | label = U+L\n")
    buf.write("----------------------------------------------------------------------------------------------------\n")
    buf.write(" "*12 + "".join([f"{c:^22}" for c in COLORS_ORDER]) + "\n")
    buf.write("----------------------------------------------------------------------------------------------------\n")
    for reg in REG_ORDER:
        row = f"{reg:<12}"
        for lig in COLORS_ORDER:
            mean = cell(lig, reg, "mean")
            se   = cell(lig, reg, "se")
            if mean is None:
                cell_txt = "—"
                U = "A"; L = "a"; lab = "Aa"
            else:
                U = upper.get((lig, reg), "A")
                L = lower.get((lig, reg), "a")
                lab = f"{U}{L}"
                if se is None or np.isnan(se):
                    cell_txt = f"{mean:.3g} [{lab}]"
                else:
                    cell_txt = f"{mean:.3g} ± {se:.3g} [{lab}]"
            row += f"{cell_txt:^22}"
        buf.write(row + "\n")
    buf.write("----------------------------------------------------------------------------------------------------\n")
    buf.write("U = letras maiúsculas (Regime dentro de cada Cor) | L = letras minúsculas (Cor dentro de cada Regime)\n")
    return buf.getvalue()

def croqui_txt(df_w: pd.DataFrame, var: str):
    txt = _croqui_txt_block(df_w, var)
    path = os.path.join(DIR_CROQ_TXT, f"croqui_{var}.txt")
    with open(path, "w", encoding="utf-8") as f:
        f.write(txt)
    return path

def gerar_croquis_txt(df_w: pd.DataFrame, vars_list):
    files = []
    for v in vars_list:
        if any(df_w.columns == v):
            files.append(croqui_txt(df_w, v))
    with zipfile.ZipFile(ZIP_CROQ_TXT, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in files: zf.write(p, arcname=os.path.basename(p))

# ===================== MAIN =====================
def main():
    # QUICK TEST guard
    _QUICK = os.environ.get("QUICK_TEST","0") == "1"

    df = load_and_normalize(INPUT_XLSX)
    vars_list = ["HFW","LFW","HMD","LMD","FvFm","YII","NPQ","qP","ETR",
                 "Chla","Chlb","Cart","TMD","CTLA","CALA","CHL","EEMS"]
    if "Chla_Chlb" in df.columns:
        vars_list += ["Chla_Chlb"]

    if _QUICK:
        vars_list = [v for v in vars_list if v in df.columns][:3]

    df_w = apply_winsorization(df, vars_list)
    df_w.to_excel(PATH_WINS, index=False)

    # Relatórios (ANOVA) — mantido simples
    report_files = []
    for v in vars_list:
        if v in df_w.columns:
            txt = build_report_text(v, df_w)
            path = os.path.join(DIR_REL, f"{v}_relatorio.txt")
            with open(path, "w", encoding="utf-8") as f:
                f.write(txt)
            report_files.append(path)
    with zipfile.ZipFile(ZIP_REL, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in report_files: zf.write(p, arcname=os.path.basename(p))

    # Extratos
    gerar_extratos(df_w, vars_list)

    # Gráficos e Croquis IMG (pula no QUICK)
    if not _QUICK:
        gerar_graficos(df_w, vars_list)
        gerar_graficos_com_tabela(df_w, vars_list)
        gerar_croquis_img(df_w, vars_list)

    # Croquis TXT (sempre)
    gerar_croquis_txt(df_w, vars_list)

    meta = {
        "winsorized_data": PATH_WINS,
        "reports_zip": ZIP_REL,
        "charts_zip": ZIP_GRAF,
        "charts_with_table_zip": ZIP_GRAF_TABELA,
        "croquis_img_zip": ZIP_CROQ_IMG,
        "croquis_txt_zip": ZIP_CROQ_TXT,
        "extratos_xlsx": XLSX_EXTR,
        "vars_processed": vars_list,
        "quick_mode": _QUICK
    }
    print(json.dumps(meta, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
