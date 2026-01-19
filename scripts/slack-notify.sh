#!/bin/bash
# Slack Notification Script for Claude Code
# Usage: slack-notify.sh <type> <message>
# Types: info, success, warning, error, attention

TYPE="${1:-info}"
MESSAGE="${2:-Notifica da Claude Code}"
PROJECT=$(basename "$(pwd)")

# Exit if no webhook configured
if [ -z "$SLACK_WEBHOOK_URL" ]; then
    exit 0
fi

# Set emoji and color based on type
case $TYPE in
    success)
        EMOJI=":white_check_mark:"
        COLOR="good"
        ;;
    warning)
        EMOJI=":warning:"
        COLOR="warning"
        ;;
    error)
        EMOJI=":x:"
        COLOR="danger"
        ;;
    attention)
        EMOJI=":bell:"
        COLOR="#439FE0"
        ;;
    deploy)
        EMOJI=":rocket:"
        COLOR="good"
        ;;
    *)
        EMOJI=":robot_face:"
        COLOR="#36a64f"
        ;;
esac

# Build JSON payload with rich formatting
PAYLOAD=$(cat <<EOF
{
    "attachments": [
        {
            "color": "$COLOR",
            "blocks": [
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": "$EMOJI *Claude Code* | \`$PROJECT\`\n$MESSAGE"
                    }
                },
                {
                    "type": "context",
                    "elements": [
                        {
                            "type": "mrkdwn",
                            "text": "$(date '+%Y-%m-%d %H:%M:%S')"
                        }
                    ]
                }
            ]
        }
    ]
}
EOF
)

# Send notification
curl -s -X POST -H 'Content-type: application/json' \
    --data "$PAYLOAD" \
    "$SLACK_WEBHOOK_URL" > /dev/null 2>&1
