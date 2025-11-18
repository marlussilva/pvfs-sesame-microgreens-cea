# -*- coding: utf-8 -*-
"""
ANOVA 2-fatores com winsorização por IQR, relatórios TXT,
extratos, croquis e gráficos de barras com:
- SE + letras
- grade horizontal e vertical
- legenda embaixo
- TABELA inferior com média ± SE e [m-SE, m+SE] por cor/regime.
"""

import os, io, re, math, zipfile, json
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from scipy import stats
from statsmodels.formula.api import ols
import statsmodels.api as sm
from statsmodels.stats.multicomp import pairwise_tukeyhsd

# ======== CONFIG ========
INPUT_XLSX = "dados.xlsx"   # ajuste se necessário
OUT_BASE   = "resultados"

DIR_REL = os.path.join(OUT_BASE, "relatorios_winsor")
DIR_GRAF = os.path.join(OUT_BASE, "graficos_barras_winsor")
DIR_GRAF_TABELA = os.path.join(OUT_BASE, "graficos_barras_winsor_tabela")
DIR_CROQ = os.path.join(OUT_BASE, "croquis_tab")

PATH_WINS = os.path.join(OUT_BASE, "dados_winsorizados.xlsx")
ZIP_REL   = os.path.join(OUT_BASE, "relatorios_winsor_ANOVA.zip")
ZIP_GRAF  = os.path.join(OUT_BASE, "graficos_barras_winsor_LETRAS_UNIDADES.zip")
ZIP_GRAF_TABELA = os.path.join(OUT_BASE, "graficos_barras_winsor_TABELA.zip")
ZIP_CROQ  = os.path.join(OUT_BASE, "croquis_tab_ALL.zip")
XLSX_EXTR = os.path.join(OUT_BASE, "extratos_winsor.xlsx")

for d in [DIR_REL, DIR_GRAF, DIR_GRAF_TABELA, DIR_CROQ]:
    os.makedirs(d, exist_ok=True)

# ======== RÓTULOS (ylabs) ========
ylabs = {
  "HFW":"HFW (Hypocotyl Fresh Mass, g)",
  "LFW":"LFW (Leaf Fresh Mass, g)",
  "HMD":"HMD (Hypocotyl Dry Mass, g)",
  "LMD":"LMD (Leaf Dry Mass, g)",
  "TMD":"TMD (Total Dry Mass, g)",
  "FvFm":r"$F_v/F_m$ (Maximum Quantum Yield of PSII)",
  "YII":"Y(II) (Effective Quantum Yield of PSII)",
  "NPQ":"NPQ (Non-Photochemical Quenching)",
  "qP":r"$q_P$ (Photochemical Quenching Coefficient)",
  "ETR":"ETR (Electron Transport Rate)",
  "Chla":r"Chla (Chlorophyll $\it{a}$, $\mu g\,g^{-1}$ FW)",
  "Chlb":r"Chlb (Chlorophyll $\it{b}$, $\mu g\,g^{-1}$ FW)",
  "Cart":r"Cart (Carotenoids, $\mu g\,g^{-1}$ FW)",
  "CTLA":r"CTLA (Total Leaf Area, cm$^2$)",
  "CALA":r"CALA (Average Leaf Area, cm$^2$)",
  "CHL":"CHL (Hypocotyl Length, cm)",
  "EEMS":r"EEMS (Energy Efficiency per Dry Matter, $\mathrm{kWh}/g$)",
  "Chla_Chlb":r"Chla/Chlb (ratio)",
}

COLORS_ORDER = ["White","RBW","Blue","Red"]
REG_ORDER    = ["Constant","Gauss"]  # na legenda exibimos "Gaussian"

# ======== HELPERS ========
def _ylim_top_and_bump(means1, se1, means2, se2, pad_frac=0.22, bump_frac=0.05):
    """
    Calcula um ylim superior seguro para caber barras+erro+letras.
    - pad_frac: folga extra acima do maior (mean+SE)
    - bump_frac: distância (fração do maior topo) para posicionar o texto
    Retorna: (ylim_top, bump)
    """
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

# ======== UTIL ========
def load_and_normalize(path_xlsx: str) -> pd.DataFrame:
    df = pd.read_excel(path_xlsx)
    df.columns = [re.sub(r"\s+", " ", str(c).replace("\xa0"," ")).strip() for c in df.columns]
    if "YII" not in df.columns and "Y2" in df.columns:
        df.rename(columns={"Y2":"YII"}, inplace=True)
    for c in list(df.columns):
        if isinstance(c, str) and c.lower().startswith("chla") and c != "Chla":
            df.rename(columns={c:"Chla"}, inplace=True)
    if "EEMS" not in df.columns and "EnE" in df.columns:
        df.rename(columns={"EnE":"EEMS"}, inplace=True)
    for c in df.columns:
        if c not in ["Regime","Ligth"] and df[c].dtype == object:
            df[c] = pd.to_numeric(df[c].astype(str).str.replace(",", ".", regex=False), errors="coerce")
    df["Regime"] = df["Regime"].astype(str).str.replace("Gaussian","Gauss", regex=False)
    df["Ligth"]  = df["Ligth"].astype(str).map(lambda x: {"RED":"Red","red":"Red"}.get(x, x))
    if any(df.columns == "Chla") and any(df.columns == "Chlb"):
        chla = df.loc[:, df.columns=="Chla"].iloc[:,0]
        chlb = df.loc[:, df.columns=="Chlb"].iloc[:,0]
        df["Chla_Chlb"] = pd.to_numeric(chla, errors="coerce") / pd.to_numeric(chlb, errors="coerce")
    return df

def winsorize_iqr(series: pd.Series) -> pd.Series:
    s = series.dropna()
    if s.size < 4:
        return series
    q1, q3 = np.percentile(s, [25, 75])
    iqr = q3 - q1
    if iqr <= 0:
        return series
    lo = q1 - 1.5*iqr
    hi = q3 + 1.5*iqr
    x = series.copy()
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
    g["se"] = g["std"] / np.sqrt(g["count"])
    means = g.pivot(index="Regime", columns="Ligth", values="mean")
    ses   = g.pivot(index="Regime", columns="Ligth", values="se")
    for c in ["Blue","RBW","Red","White"]:
        if c not in means.columns:
            means[c] = np.nan; ses[c] = np.nan
    means = means[["Blue","RBW","Red","White"]]
    ses   = ses[["Blue","RBW","Red","White"]]
    return means, ses

def format_anova_table(aov, tss, tdf):
    name_map = {"C(Regime)":"Regime", "C(Ligth)":"Cor", "C(Regime):C(Ligth)":"Regime*Cor", "Residual":"Residuo"}
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
            def fmt(x, nd=4):
                if x=="" or x is None or (isinstance(x,(float,np.floating)) and (np.isnan(x) or np.isinf(x))):
                    return ""
                return f"{x:.{nd}f}"
            buf.write(f"{name:<12}{dfv:>5} {fmt(ss):>9} {fmt(ms):>7} {fmt(F):>7} {fmt(p):>8}\n")
    buf.write(f"{'Total':<12}{int(tdf):>5} {tss:>9.4f} {'':>7} {'':>7} {'':>8}\n")
    buf.write("------------------------------------------------------------------------\n")
    return buf.getvalue()

def print_table_like_expdes(means_df, ses_df):
    buf = io.StringIO()
    buf.write("Interação Regime x Cor:\n")
    for cols in [["Blue","RBW","Red"], ["White"]]:
        buf.write("         " + "  ".join([f"{c:<18}" for c in cols]) + "\n")
        for reg in means_df.index:
            row_vals = []
            for c in cols:
                val = means_df.loc[reg, c] if c in means_df.columns else np.nan
                row_vals.append(f"\"{val}\"")
            buf.write(f"{reg:<9} " + " ".join(row_vals) + "\n")
    buf.write("         " + "  ".join([f"{c:<18}" for c in ["Blue","RBW","Red"]]) + "\n")
    for reg in ses_df.index:
        row_vals = [f"\"{ses_df.loc[reg, c]}\"" for c in ["Blue","RBW","Red"]]
        buf.write(f"{reg:<9} " + " ".join(row_vals) + "\n")
    buf.write("         " + "  ".join([f"{c:<18}" for c in ["White","Letras"]]) + "\n")
    for reg in ses_df.index:
        val = ses_df.loc[reg, "White"] if "White" in ses_df.columns else np.nan
        buf.write(f"{reg:<9} " + " ".join([f"\"{val}\"", "\"\""]) + "\n")
    buf.write("\n\n")
    return buf.getvalue()

# ======== Letras (com checagens para evitar warnings) ========
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
    if mc is not None and hasattr(mc,"reject") and mc.reject.size>=1 and bool(mc.reject[0]):
        return {means.index[0]:"A", means.index[1]:"B"}
    return {k:"A" for k in means.index}

# ======== Relatórios / Desdobramentos ========
def build_report_text(varname: str, df_in: pd.DataFrame) -> str:
    model, aov, mse, sh_p, tss, tdf, sub = anova_two_way(df_in, varname)
    means_df, ses_df = means_se_by_cell(sub, varname)
    cv = cv_percent(mse, sub[varname])
    buf = io.StringIO()
    buf.write(f"Análise da variável: {varname} \n\n")
    buf.write(print_table_like_expdes(means_df, ses_df))
    buf.write("------------------------------------------------------------------------\n")
    buf.write("Legenda:\nFATOR 1:  Regime \nFATOR 2:  Cor \n")
    buf.write("------------------------------------------------------------------------\n\n\n")
    buf.write(format_anova_table(aov, tss, tdf))
    buf.write(f"CV = {cv:.2f} %\n\n")
    buf.write("------------------------------------------------------------------------\n")
    buf.write("Teste de normalidade dos residuos (Shapiro-Wilk)\n")
    buf.write(f"valor-p:  {sh_p} \n")
    if sh_p < 0.05:
        buf.write("ATENCAO: a 5% de significancia, os residuos nao podem ser considerados normais!\n")
    buf.write("------------------------------------------------------------------------\n")
    p_int = aov.loc["C(Regime):C(Ligth)","PR(>F)"]
    if p_int < 0.05:
        buf.write(section_desdobramento_regime(sub, varname))
        buf.write(section_desdobramento_cor(sub, varname))
    else:
        buf.write("\n\nInteracao nao significativa a 5%; desdobramentos omitidos.\n")
    return buf.getvalue()

def section_desdobramento_regime(df_in, ycol):
    buf = io.StringIO()
    buf.write("\n\n\nInteracao significativa: desdobrando a interacao\n")
    buf.write("------------------------------------------------------------------------\n\n")
    buf.write("Desdobrando  Regime  dentro de cada nivel de  Cor \n")
    buf.write("------------------------------------------------------------------------\n")
    buf.write("------------------------------------------------------------------------\n")
    buf.write("Quadro da analise de variancia\n")
    buf.write("------------------------------------------------------------------------\n")
    rows = []
    model_cor = ols(f"{ycol} ~ C(Ligth)", data=df_in.dropna(subset=[ycol])).fit()
    a_cor = sm.stats.anova_lm(model_cor, typ=2)
    rows.append(("Cor", int(a_cor.loc["C(Ligth)","df"]), float(a_cor.loc["C(Ligth)","sum_sq"]),
                 float(a_cor.loc["C(Ligth)","sum_sq"]/a_cor.loc["C(Ligth)","df"]),
                 float(a_cor.loc["C(Ligth)","F"]), float(a_cor.loc["C(Ligth)","PR(>F)"])) )
    for col in [c for c in ["Blue","RBW","Red","White"] if c in df_in["Ligth"].unique().tolist()]:
        sub = df_in[df_in["Ligth"]==col].dropna(subset=[ycol])
        if sub["Regime"].nunique() > 1:
            model = ols(f"{ycol} ~ C(Regime)", data=sub).fit()
            a = sm.stats.anova_lm(model, typ=2)
            rows.append((f"Regime:Cor {col}", int(a.loc["C(Regime)","df"]),
                        float(a.loc["C(Regime)","sum_sq"]),
                        float(a.loc["C(Regime)","sum_sq"]/a.loc["C(Regime)","df"]),
                        float(a.loc["C(Regime)","F"]),
                        float(a.loc["C(Regime)","PR(>F)"])) )
    buf.write(f"{'':<17}{'GL':>6}{'SQ':>9}{'QM':>9}{'Fc':>8}{'Pr.Fc':>8}\n")
    for name, gl, sq, qm, fc, p in rows:
        buf.write(f"{name:<17}{gl:>6} {sq:>9.5f} {qm:>9.5f} {fc:>8.4f} {p:>8.4f}\n")
    buf.write("------------------------------------------------------------------------\n\n")
    for col in [c for c in ["Blue","RBW","Red","White"] if c in df_in["Ligth"].unique().tolist()]:
        sub = df_in[df_in["Ligth"]==col].dropna(subset=[ycol])
        buf.write(f"\n\n Regime  dentro do nivel  {col}  de  Cor \n")
        buf.write("------------------------------------------------------------------------\n")
        if sub["Regime"].nunique() <= 1:
            buf.write("Dados insuficientes.\n------------------------------------------------------------------------\n")
            continue
        model = ols(f"{ycol} ~ C(Regime)", data=sub).fit()
        a = sm.stats.anova_lm(model, typ=2)
        p = a.loc["C(Regime)","PR(>F)"]
        if p < 0.05:
            buf.write("Teste de Tukey\n")
            buf.write("------------------------------------------------------------------------\n")
            tuk = pairwise_tukeyhsd(sub[ycol].values, sub["Regime"].astype(str).values, alpha=0.05)
            means = sub.groupby("Regime")[ycol].mean().sort_values(ascending=False)
            groups = {k:"A" for k in means.index}
            if tuk.reject.size>=1 and bool(tuk.reject[0]):
                top, low = means.index[0], means.index[1]
                groups[top] = "A"; groups[low] = "B"
            buf.write("Grupos Tratamentos Medias\n")
            for k,v in means.items():
                buf.write(f"{groups[k]:<2}\t {k}\t {v:.6g} \n")
            buf.write("------------------------------------------------------------------------\n")
        else:
            buf.write("\nDe acordo com o teste F, as medias desse fator sao estatisticamente iguais.\n")
            buf.write("------------------------------------------------------------------------\n")
            means = sub.groupby("Regime")[ycol].mean()
            buf.write(f"{'Niveis':<10}{'Medias':>10}\n")
            for k,v in means.items():
                buf.write(f"{k:<10}{v:>10.6f}\n")
            buf.write("------------------------------------------------------------------------\n")
    return buf.getvalue()

def section_desdobramento_cor(df_in, ycol):
    buf = io.StringIO()
    buf.write("\n\n\nDesdobrando  Cor  dentro de cada nivel de  Regime \n")
    buf.write("------------------------------------------------------------------------\n")
    buf.write("------------------------------------------------------------------------\n")
    buf.write("Quadro da analise de variancia\n")
    buf.write("------------------------------------------------------------------------\n")
    rows = []
    model_reg = ols(f"{ycol} ~ C(Regime)", data=df_in.dropna(subset=[ycol])).fit()
    a_reg = sm.stats.anova_lm(model_reg, typ=2)
    rows.append(("Regime", int(a_reg.loc["C(Regime)","df"]), float(a_reg.loc["C(Regime)","sum_sq"]),
                 float(a_reg.loc["C(Regime)","sum_sq"]/a_reg.loc["C(Regime)","df"]),
                 float(a_reg.loc["C(Regime)","F"]), float(a_reg.loc["C(Regime)","PR(>F)"])) )
    for reg in [r for r in ["Constant","Gauss"] if r in df_in["Regime"].unique().tolist()] :
        sub = df_in[df_in["Regime"]==reg].dropna(subset=[ycol])
        if sub["Ligth"].nunique() > 1:
            model = ols(f"{ycol} ~ C(Ligth)", data=sub).fit()
            a = sm.stats.anova_lm(model, typ=2)
            rows.append((f"Cor:Regime {reg}", int(a.loc["C(Ligth)","df"]),
                         float(a.loc["C(Ligth)","sum_sq"]),
                         float(a.loc["C(Ligth)","sum_sq"]/a.loc["C(Ligth)","df"]),
                         float(a.loc["C(Ligth)","F"]),
                         float(a.loc["C(Ligth)","PR(>F)"])) )
    buf.write(f"{'':<22}{'GL':>6}{'SQ':>9}{'QM':>9}{'Fc':>8}{'Pr.Fc':>8}\n")
    for name, gl, sq, qm, fc, p in rows:
        buf.write(f"{name:<22}{gl:>6} {sq:>9.5f} {qm:>9.5f} {fc:>8.4f} {p:>8.4f}\n")
    buf.write("------------------------------------------------------------------------\n\n")
    for reg in [r for r in ["Constant","Gauss"] if r in df_in["Regime"].unique().tolist()]:
        sub = df_in[df_in["Regime"]==reg].dropna(subset=[ycol])
        buf.write(f"\n\n Cor  dentro do nivel  {reg}  de  Regime \n")
        buf.write("------------------------------------------------------------------------\n")
        if sub["Ligth"].nunique() <= 1:
            buf.write("Dados insuficientes.\n------------------------------------------------------------------------\n")
            continue
        model = ols(f"{ycol} ~ C(Ligth)", data=sub).fit()
        a = sm.stats.anova_lm(model, typ=2)
        p = a.loc["C(Ligth)","PR(>F)"]
        if p < 0.05:
            buf.write("Teste de Tukey\n")
            buf.write("------------------------------------------------------------------------\n")
            letters = tukey_letters_colors(sub, ycol)
            means = sub.groupby("Ligth")[ycol].mean().sort_values(ascending=False)
            buf.write("Grupos Tratamentos Medias\n")
            for lig, mean in means.items():
                let = letters.get(lig, "a")
                buf.write(f"{let:<2}\t {lig} \t {mean:.6g} \n")
            buf.write("------------------------------------------------------------------------\n")
        else:
            buf.write("\nDe acordo com o teste F, as medias desse fator sao estatisticamente iguais.\n")
            buf.write("------------------------------------------------------------------------\n")
            means = sub.groupby("Ligth")[ycol].mean()
            buf.write(f"{'Niveis':<10}{'Medias':>10}\n")
            for k,v in means.items():
                buf.write(f"{k:<10}{v:>10.6f}\n")
            buf.write("------------------------------------------------------------------------\n")
    return buf.getvalue()

# ======== Extratos ========
def gerar_extratos(df_w: pd.DataFrame, vars_list):
    with pd.ExcelWriter(XLSX_EXTR, engine="openpyxl") as writer:
        for v in vars_list:
            if v not in df_w.columns: 
                continue
            sub = df_w[["Regime","Ligth", v]].dropna().copy()
            lower = {}
            for reg in ["Constant","Gauss"]:
                m = sub["Regime"]==reg
                if m.any():
                    mletters = tukey_letters_colors(sub[m].rename(columns={v:"y"}),"y")
                    lower.update({(k,reg):val for k,val in mletters.items()})
            upper = {}
            for lig in ["White","RBW","Blue","Red"]:
                m = sub["Ligth"]==lig
                if m.any():
                    uletters = upper_letter_regime_within_color(sub[m].rename(columns={v:"y"}),"y")
                    for reg, val in uletters.items():
                        upper[(lig, reg)] = val
            g = sub.groupby(["Regime","Ligth"], observed=True)[v]
            agg = pd.DataFrame({"count": g.count(), "mean": g.mean(), "std": g.std()}).reset_index()
            agg["se"] = agg["std"] / np.sqrt(agg["count"].replace(0, np.nan))
            vals = (sub.groupby(["Regime","Ligth"], observed=True)[v]
                      .apply(lambda s: "; ".join([f"{x:.6g}" for x in s.tolist()])))
            vals = vals.reset_index().rename(columns={v:"values"})
            tab = agg.merge(vals, on=["Regime","Ligth"], how="left")
            tab["U"] = tab.apply(lambda r: upper.get((r["Ligth"], r["Regime"]), "A"), axis=1)
            tab["L"] = tab.apply(lambda r: lower.get((r["Ligth"], r["Regime"]), "a"), axis=1)
            tab["label"] = tab["U"] + tab["L"]
            tab = tab[["Regime","Ligth","count","mean","se","U","L","label","values"]]
            tab.to_excel(writer, sheet_name=v[:31], index=False)

# ======== GRÁFICOS ========
def grafico_barras(df_w: pd.DataFrame, var: str):
    y = df_w.loc[:, df_w.columns==var].iloc[:,0]
    sub = pd.DataFrame({"Regime": df_w["Regime"], "Ligth": df_w["Ligth"], var: y}).dropna()
    if sub.empty: 
        return None

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

    g = sub.groupby(["Ligth","Regime"], observed=True)[var]
    agg = pd.DataFrame({"mean": g.mean(), "count": g.count(), "std": g.std()}).reset_index()
    agg["se"] = agg["std"] / np.sqrt(agg["count"].replace(0, np.nan))
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
        return [plot_df[(plot_df["Ligth"]==c) & (plot_df["Regime"]==reg)][field].mean() for c in COLORS_ORDER]
    mC, sC = series("Constant","mean"), series("Constant","se")
    mG, sG = series("Gauss","mean"), series("Gauss","se")

    ax.bar(x - width/2, mC, width, yerr=sC, capsize=4, label="Constant")
    ax.bar(x + width/2, mG, width, yerr=sG, capsize=4, label="Gaussian")

    ax.set_xticks(x); ax.set_xticklabels(COLORS_ORDER)
    ax.set_ylabel(ylabs.get(var, var))
    # >>> REMOVIDO: ax.set_title(var)

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
    """Versão COM a tabela inferior de média±SE e intervalo [m-SE, m+SE]."""
    y = df_w.loc[:, df_w.columns==var].iloc[:,0]
    sub = pd.DataFrame({"Regime": df_w["Regime"], "Ligth": df_w["Ligth"], var: y}).dropna()
    if sub.empty: 
        return None
    g = sub.groupby(["Ligth","Regime"], observed=True)[var]
    agg = pd.DataFrame({"mean": g.mean(), "count": g.count(), "std": g.std()}).reset_index()
    agg["se"] = agg["std"] / np.sqrt(agg["count"].replace(0, np.nan))
    agg["low"] = agg["mean"] - agg["se"]
    agg["high"] = agg["mean"] + agg["se"]

    # letras
    lower = {}; upper = {}
    for reg in REG_ORDER:
        m = sub["Regime"]==reg
        if m.any():
            lower.update({(k,reg):val for k,val in tukey_letters_colors(sub[m].rename(columns={var:"y"}),"y").items()})
    for lig in COLORS_ORDER:
        m = sub["Ligth"]==lig
        if m.any():
            up = upper_letter_regime_within_color(sub[m].rename(columns={var:"y"}),"y")
            for reg, val in up.items(): upper[(lig, reg)] = val

    agg["U"] = agg.apply(lambda r: upper.get((r["Ligth"], r["Regime"]), "A"), axis=1)
    agg["L"] = agg.apply(lambda r: lower.get((r["Ligth"], r["Regime"]), "a"), axis=1)
    agg["label"] = agg["U"] + agg["L"]

    plot_df = agg.copy()
    plot_df["Ligth"] = pd.Categorical(plot_df["Ligth"], categories=COLORS_ORDER, ordered=True)
    plot_df["Regime"] = pd.Categorical(plot_df["Regime"], categories=REG_ORDER, ordered=True)
    plot_df = plot_df.sort_values(["Ligth","Regime"])

    # Figura com GridSpec (gráfico + tabela)
    import matplotlib.gridspec as gridspec
    fig = plt.figure(figsize=(8.6,6.2), dpi=140)
    gs = gridspec.GridSpec(2, 1, height_ratios=[3.6, 1.6])
    ax = fig.add_subplot(gs[0])
    axt = fig.add_subplot(gs[1]); axt.axis("off")

    x = np.arange(len(COLORS_ORDER)); width = 0.36
    def series(reg, field):
        return [plot_df[(plot_df["Ligth"]==c) & (plot_df["Regime"]==reg)][field].mean() for c in COLORS_ORDER]
    mC, sC = series("Constant","mean"), series("Constant","se")
    mG, sG = series("Gauss","mean"), series("Gauss","se")

    ax.bar(x - width/2, mC, width, yerr=sC, capsize=4, label="Constant")
    ax.bar(x + width/2, mG, width, yerr=sG, capsize=4, label="Gaussian")

    ax.set_xticks(x); ax.set_xticklabels(COLORS_ORDER)
    ax.set_ylabel(ylabs.get(var, var))
    ax.set_title(var)

    ax.set_axisbelow(True)
    ax.grid(which='major', axis='y', linestyle='--', alpha=0.5)
    ax.grid(which='major', axis='x', linestyle='--', alpha=0.3)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.12), ncol=2, frameon=False)

    # folga superior robusta + letras
    ylim_top, bump = _ylim_top_and_bump(mC, sC, mG, sG, pad_frac=0.22, bump_frac=0.05)
    ax.set_ylim(top=ylim_top)
    label_map = {(row.Ligth, row.Regime): row.label for _, row in plot_df.iterrows()}
    for i, c in enumerate(COLORS_ORDER):
        if np.isfinite(mC[i]):
            ax.text(x[i]-width/2,
                    mC[i] + (sC[i] if np.isfinite(sC[i]) else 0) + bump,
                    label_map.get((c, "Constant"), ""),
                    ha='center', va='bottom', fontsize=9, clip_on=False)
        if np.isfinite(mG[i]):
            ax.text(x[i]+width/2,
                    mG[i] + (sG[i] if np.isfinite(sG[i]) else 0) + bump,
                    label_map.get((c, "Gauss"), ""),
                    ha='center', va='bottom', fontsize=9, clip_on=False)

    # Tabela com média±SE e [low, high]
    rows = []
    for reg in REG_ORDER:
        r = []
        for col in COLORS_ORDER:
            m = plot_df[(plot_df["Ligth"]==col) & (plot_df["Regime"]==reg)]
            if len(m)==0:
                r.append("—")
            else:
                mean = float(m["mean"].values[0]); se = float(m["se"].values[0])
                low  = float(m["low"].values[0]);  high= float(m["high"].values[0])
                r.append(f"{mean:.3g} ± {se:.3g}\n[{low:.3g}, {high:.3g}]")
        rows.append(r)
    table = axt.table(cellText=rows, rowLabels=["Constant","Gaussian"], colLabels=COLORS_ORDER,
                      cellLoc='center', loc='center')
    table.auto_set_font_size(False); table.set_fontsize(9); table.scale(1, 1.3)

    fig.subplots_adjust(top=0.90, bottom=0.10, hspace=0.06)

    png = os.path.join(DIR_GRAF_TABELA, f"{var}_barras_tabela.png")
    pdf = os.path.join(DIR_GRAF_TABELA, f"{var}_barras_tabela.pdf")
    fig.savefig(png, bbox_inches="tight", pad_inches=0.05)
    fig.savefig(pdf, bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    return [png, pdf]

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

# ======== Croquis ========
def croqui_mean_se(df_w: pd.DataFrame, var: str):
    y = df_w.loc[:, df_w.columns==var].iloc[:,0]
    sub = pd.DataFrame({"Regime": df_w["Regime"], "Ligth": df_w["Ligth"], var: y}).dropna()
    if sub.empty:
        return None
    g = sub.groupby(["Ligth","Regime"], observed=True)[var].agg(["mean","count","std"]).reset_index()
    g["se"] = g["std"] / np.sqrt(g["count"])
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
    ax.set_title(f"{var} — média ± erro-padrão (winsorização IQR)")
    png = os.path.join(DIR_CROQ, f"croqui_tab_{var}.png")
    pdf = os.path.join(DIR_CROQ, f"croqui_tab_{var}.pdf")
    plt.savefig(png, bbox_inches="tight", pad_inches=0.05)
    plt.savefig(pdf, bbox_inches="tight", pad_inches=0.05)
    plt.close(fig)
    return [png, pdf]

def gerar_croquis(df_w: pd.DataFrame, vars_list):
    files = []
    for v in vars_list:
        if any(df_w.columns == v):
            out = croqui_mean_se(df_w, v)
            if out: files += out
    with zipfile.ZipFile(ZIP_CROQ, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in files: zf.write(p, arcname=os.path.basename(p))

# ======== MAIN ========
def main():
    df = load_and_normalize(INPUT_XLSX)
    vars_list = ["HFW","LFW","HMD","LMD","FvFm","YII","NPQ","qP","ETR",
                 "Chla","Chlb","Cart","TMD","CTLA","CALA","CHL","EEMS"]
    if "Chla_Chlb" in df.columns:
        vars_list += ["Chla_Chlb"]

    df_w = apply_winsorization(df, vars_list)
    df_w.to_excel(PATH_WINS, index=False)

    # Relatórios
    files = []
    for v in vars_list:
        if v in df_w.columns:
            txt = build_report_text(v, df_w)
            path = os.path.join(DIR_REL, f"{v}_relatorio.txt")
            with open(path, "w", encoding="utf-8") as f:
                f.write(txt)
            files.append(path)
    with zipfile.ZipFile(ZIP_REL, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in files: zf.write(p, arcname=os.path.basename(p))

    # Extratos
    gerar_extratos(df_w, vars_list)

    # Gráficos (sem e com a tabela)
    gerar_graficos(df_w, vars_list)
    gerar_graficos_com_tabela(df_w, vars_list)

    # Croquis
    gerar_croquis(df_w, vars_list)

    meta = {
        "winsorized_data": PATH_WINS,
        "reports_zip": ZIP_REL,
        "charts_zip": ZIP_GRAF,
        "charts_with_table_zip": ZIP_GRAF_TABELA,
        "croquis_zip": ZIP_CROQ,
        "extratos_xlsx": XLSX_EXTR
    }
    print(json.dumps(meta, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
