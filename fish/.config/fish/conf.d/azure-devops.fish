# Azure DevOps Fish Shell Integration
# Save to: ~/.config/fish/conf.d/azure-devops.fish

# Configuration
set -gx AZURE_DEVOPS_ORG "https://dev.azure.com/bfh-services"
set -gx AZURE_DEVOPS_PROJECT "Virtuelle Akademie"
# set -gx AZURE_DEVOPS_PAT "your-pat-here"  # Set this separately!

# Abbreviations (expand as you type)
abbr -a azi "az boards work-item"
abbr -a azq "az boards query"

# My active work items
function az-my-items
    az boards query \
        --wiql "SELECT [Id], [Title], [State], [Priority] FROM workitems WHERE [System.AssignedTo] = @Me AND [System.State] NOT IN ('Done', 'Closed') ORDER BY [Priority]" \
        --project "$AZURE_DEVOPS_PROJECT" \
        --output table
end

# My items as JSON (for piping)
function az-my-items-json
    az boards query \
        --wiql "SELECT [Id], [Title], [State], [Priority] FROM workitems WHERE [System.AssignedTo] = @Me AND [System.State] NOT IN ('Done', 'Closed') ORDER BY [Priority]" \
        --project "$AZURE_DEVOPS_PROJECT" \
        --output json
end

# Active PRs
function az-active-prs
    az repos pr list --status active --output table
end

# My PRs
function az-my-prs
    az repos pr list --status active --project "$AZURE_DEVOPS_PROJECT" --output table
end

# Show work item details
function az-item
    if test -z "$argv[1]"
        echo "Usage: az-item <work-item-id>"
        return 1
    end
    az boards work-item show --id $argv[1] --output yaml
end

# Open work item in browser
function az-item-open
    if test -z "$argv[1]"
        echo "Usage: az-item-open <work-item-id>"
        return 1
    end
    set -l encoded_project (string replace -a ' ' '%20' "$AZURE_DEVOPS_PROJECT")
    set -l url "$AZURE_DEVOPS_ORG/$encoded_project/_workitems/edit/$argv[1]"
    open "$url"
end

# Create a new task
function az-create-task
    if test -z "$argv[1]"
        echo "Usage: az-create-task \"Task title\""
        return 1
    end
    az boards work-item create \
        --type "Task" \
        --title "$argv[1]" \
        --assigned-to "@Me" \
        --project "$AZURE_DEVOPS_PROJECT"
end

# Create a new bug
function az-create-bug
    if test -z "$argv[1]"
        echo "Usage: az-create-bug \"Bug title\""
        return 1
    end
    az boards work-item create \
        --type "Bug" \
        --title "$argv[1]" \
        --assigned-to "@Me" \
        --project "$AZURE_DEVOPS_PROJECT"
end

# Update work item state
function az-item-state
    if test -z "$argv[1]"; or test -z "$argv[2]"
        echo "Usage: az-item-state <work-item-id> <state>"
        echo "States: New, Active, Resolved, Closed, Done"
        return 1
    end
    az boards work-item update --id $argv[1] --state "$argv[2]"
end

# Interactive work item selector using fzf
function az-item-select
    az boards query \
        --wiql "SELECT [Id], [Title], [State] FROM workitems WHERE [System.AssignedTo] = @Me AND [System.State] NOT IN ('Done', 'Closed')" \
        --project "$AZURE_DEVOPS_PROJECT" \
        --output tsv 2>/dev/null \
    | fzf --header="Select work item" \
    | cut -f1
end

# Open selected work item in browser
function az-item-fzf
    set -l id (az-item-select)
    if test -n "$id"
        az-item-open $id
    end
end

# Checkout PR using fzf
function az-pr-checkout
    set -l pr_id (az repos pr list --status active --output table | tail -n +3 | fzf --header="Select PR to checkout" | awk '{print $1}')
    if test -n "$pr_id"
        az repos pr checkout --id $pr_id
    end
end

# Standup helper
function az-standup
    echo "=== My Active Work Items ==="
    az-my-items
    echo ""
    echo "=== My Active PRs ==="
    az-my-prs
end

# Export to org-mode format
function az-items-to-org
    az-my-items-json | jq -r '.[] | "* TODO \(.fields."System.Title")\n:PROPERTIES:\n:TICKET_ID: \(.id)\n:STATE: \(.fields."System.State")\n:END:\n"'
end

# echo "Azure DevOps functions loaded: az-my-items, az-standup, az-item-fzf, az-item-open"
