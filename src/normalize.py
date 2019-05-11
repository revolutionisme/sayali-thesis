import difflib


def fix_spelling(x, source, cutoff=0.6):
    try:
        return difflib.get_close_matches(x, source, cutoff=cutoff)[0]
    except Exception:
        return "NA"
