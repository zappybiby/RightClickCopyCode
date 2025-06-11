<#
Copies the chosen file to the clipboard wrapped like:

    filename.ext (C:\full\path\filename.ext)
    ```<language>
    …file contents…
    ```
#>

param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string] $Path
)

# 1) Read the entire file
$code = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)

# 2) Build the label line
$filename = [System.IO.Path]::GetFileName($Path)
$label    = "$filename ($Path)"

# 3) Map extensions to fence languages
$ext2lang = @{
    '.adoc'       = 'asciidoc'
    '.bash'       = 'bash'
    '.c'          = 'c'
    '.coffee'     = 'coffeescript'
    '.cpp'        = 'cpp'
    '.cr'         = 'crystal'
    '.cs'         = 'csharp'
    '.css'        = 'css'
    '.diff'       = 'diff'
    '.dockerfile' = 'dockerfile'
    '.ex'         = 'elixir'
    '.gcode'      = 'gcode'
    '.go'         = 'go'
    '.hbs'        = 'handlebars'
    '.html'       = 'html'
    '.htaccess'   = 'apache'
    '.ini'        = 'ini'
    '.java'       = 'java'
    '.js'         = 'javascript'
    '.json'       = 'json'
    '.kt'         = 'kotlin'
    '.lua'        = 'lua'
    '.md'         = 'markdown'
    '.m'          = 'objectivec'
    '.mk'         = 'makefile'
    '.pl'         = 'perl'
    '.phtml'      = 'php-template'
    '.php'        = 'php'
    '.ps1'        = 'powershell'
    '.py'         = 'python'
    '.r'          = 'r'
    '.rb'         = 'ruby'
    '.rs'         = 'rust'
    '.scss'       = 'scss'
    '.sh'         = 'shell'
    '.sqf'        = 'sqf'
    '.sql'        = 'sql'
    '.swift'      = 'swift'
    '.tex'        = 'latex'
    '.toml'       = 'toml'
    '.ts'         = 'typescript'
    '.xquery'     = 'xquery'
    '.xml'        = 'xml'
    '.yaml'       = 'yaml'
    '.txt'        = 'plaintext'
}

# 4) Lookup the language (or leave blank if unknown)
$ext  = [System.IO.Path]::GetExtension($Path).ToLower()
$lang = if ($ext2lang.ContainsKey($ext)) { $ext2lang[$ext] } else { '' }

# 5) Compose the fenced code block
$threeTicks = '```' # Store literal triple backticks
$wrapped = @"
$label
$($threeTicks)$($lang)
$code
$($threeTicks)
"@

# 6) Copy to clipboard
Set-Clipboard -Value $wrapped
