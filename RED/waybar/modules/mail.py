#!/usr/bin/python

# ─────────────────────────────────────────────────────────────────
# ATENÇÃO: este módulo depende de um arquivo mailsecrets.py que
# NÃO está incluído no repositório por razões de segurança.
# Crie o arquivo em ~/.config/waybar/modules/mailsecrets.py com:
#
#   username = "seu@email.com"
#   password = "sua_senha_ou_app_password"
#   server   = "imap.seuservidor.com"
#
# Sem esse arquivo, este módulo silenciosamente não exibe nada.
# ─────────────────────────────────────────────────────────────────

import os
import imaplib
import sys

try:
    import mailsecrets
except ImportError:
    sys.exit(1)

def getmails(username, password, server):
    imap = imaplib.IMAP4_SSL(server, 993)
    imap.login(username, password)
    imap.select('INBOX')
    ustatus, uresponse = imap.uid('search', None, 'UNSEEN')
    if ustatus == 'OK':
        unread_msg_nums = uresponse[0].split()
    else:
        unread_msg_nums = []

    fstatus, fresponse = imap.uid('search', None, 'FLAGGED')
    if fstatus == 'OK':
        flagged_msg_nums = fresponse[0].split()
    else:
        flagged_msg_nums = []

    return [len(unread_msg_nums), len(flagged_msg_nums)]

ping = os.system("ping " + mailsecrets.server + " -c1 > /dev/null 2>&1")
if ping == 0:
    mails = getmails(mailsecrets.username, mailsecrets.password, mailsecrets.server)
    text = ''
    alt = ''

    if mails[0] > 0:
        text = alt = str(mails[0])
        if mails[1] > 0:
            alt = str(mails[1]) + "  " + alt
    else:
        exit(1)

    print('{"text":"' + text + '", "alt": "' + alt + '"}')

else:
    exit(1)