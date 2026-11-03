# Issues are classified by type, area, and priority labels set by forms and the sidebar

A personal repository has neither GitHub's issue types nor an organization's issue fields, so type, area, and priority are labels: `type:` is applied by the issue form, `area:` and `priority:` are set in the sidebar. The labels themselves, with their descriptions, are the only definition of each area; CONTRIBUTING.md points to the labels page instead of repeating the list.

Area and priority dropdowns in the issue forms, applied as labels by a workflow, were rejected: issue forms are static, so every new area would have to be added to each form as well as to the labels, or the forms generated from a labels file with a check that they match. Forgetting an area label in the sidebar is the accepted cost.
