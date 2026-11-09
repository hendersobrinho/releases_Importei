# Importei: versões para instalar

Este repositório só guarda os pacotes de instalação do Importei. O programa instalado procura aqui a versão mais nova ao abrir e se atualiza sozinho.

## Instalar

No PowerShell, rode:

```powershell
irm https://raw.githubusercontent.com/hendersobrinho/releases_Importei/main/Install-Importei.ps1 | iex
```

O instalador baixa a última versão, confere o SHA-256 do pacote, copia para `%LOCALAPPDATA%\Programs\Importei` e cria um atalho na área de trabalho. Feche o Importei antes de instalar por cima de uma versão aberta.

Os pacotes estão em [Releases](../../releases).
