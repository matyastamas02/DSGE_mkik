# Codex munkafolyamat-szabályok

## GitHub-jogosultság

- A Codex dolgozhat a helyi munkafán: fájlokat olvashat és módosíthat, valamint teszteket és ellenőrzéseket futtathat.
- A Codex **nem frissítheti a GitHubot**. Nem commitolhat, nem pusholhat, nem hozhat létre vagy módosíthat pull requestet, issue-t, release-t, taget vagy más GitHub-erőforrást.
- A GitHubbal kapcsolatos minden írási műveletet, beleértve a commitot és a pusht, **kizárólag Claude** végezhet.
- A Codex csak olvasási célú Git/GitHub-ellenőrzéseket végezhet (például `git status`, `git diff`, `git log`, `git show`, `git remote -v`).
- Ha a feladat GitHub-frissítést igényel, a Codex készítse elő és ellenőrizze a helyi változtatásokat, majd adja át őket Claude-nak commitolásra és pusholásra.
