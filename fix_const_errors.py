import json
import os

# JSON representation of the compiler errors
errors_data = [
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/components/premium_background.dart","message":"The named parameter 'isLight' isn't defined.\nTry correcting the name to an existing named parameter's name, or defining a named parameter with the name 'isLight'.","severity":"error","startLine":61,"endLine":61},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":380,"endLine":380},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":427,"endLine":427},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":431,"endLine":431},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":506,"endLine":506},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":511,"endLine":511},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":572,"endLine":572},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":605,"endLine":605},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":609,"endLine":609},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":614,"endLine":614},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/ai_assistant/ai_assistant_screen.dart","message":"Invalid constant value.","severity":"error","startLine":668,"endLine":668},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":45,"endLine":45},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":119,"endLine":119},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":164,"endLine":164},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":188,"endLine":188},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":234,"endLine":234},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":238,"endLine":238},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":279,"endLine":279},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/analytics/analytics_screen.dart","message":"Invalid constant value.","severity":"error","startLine":280,"endLine":280},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/auth/auth_screen.dart","message":"Invalid constant value.","severity":"error","startLine":175,"endLine":175},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/auth/auth_screen.dart","message":"Invalid constant value.","severity":"error","startLine":205,"endLine":205},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/auth/auth_screen.dart","message":"Invalid constant value.","severity":"error","startLine":224,"endLine":224},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/auth/auth_screen.dart","message":"Invalid constant value.","severity":"error","startLine":402,"endLine":402},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/auth/auth_screen.dart","message":"Invalid constant value.","severity":"error","startLine":429,"endLine":429},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/auth/auth_screen.dart","message":"Invalid constant value.","severity":"error","startLine":439,"endLine":439},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":145,"endLine":145},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":160,"endLine":160},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":171,"endLine":171},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":188,"endLine":188},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":214,"endLine":214},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":240,"endLine":240},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":256,"endLine":256},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":272,"endLine":272},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":287,"endLine":287},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":301,"endLine":301},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":316,"endLine":316},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_create_screen.dart","message":"Invalid constant value.","severity":"error","startLine":346,"endLine":346},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":47,"endLine":47},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":64,"endLine":64},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":103,"endLine":103},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":107,"endLine":107},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":149,"endLine":149},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":160,"endLine":160},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":181,"endLine":181},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":201,"endLine":201},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":233,"endLine":233},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":241,"endLine":241},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":249,"endLine":249},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":256,"endLine":256},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":261,"endLine":261},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":267,"endLine":267},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":285,"endLine":285},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":303,"endLine":303},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":315,"endLine":315},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bug_detail_screen.dart","message":"Invalid constant value.","severity":"error","startLine":354,"endLine":354},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":71,"endLine":71},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":76,"endLine":76},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":118,"endLine":118},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":133,"endLine":133},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":160,"endLine":160},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":196,"endLine":196},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":200,"endLine":200},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":207,"endLine":207},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/bugs/bugs_list_screen.dart","message":"Invalid constant value.","severity":"error","startLine":212,"endLine":212},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":89,"endLine":89},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":95,"endLine":95},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":103,"endLine":103},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":208,"endLine":208},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":226,"endLine":226},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":240,"endLine":240},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":269,"endLine":269},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":325,"endLine":325},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":334,"endLine":334},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":346,"endLine":346},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_client_dialog.dart","message":"Invalid constant value.","severity":"error","startLine":350,"endLine":350},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":134,"endLine":134},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":149,"endLine":149},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":189,"endLine":189},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":229,"endLine":229},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":235,"endLine":235},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":242,"endLine":242},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":258,"endLine":258},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":262,"endLine":262},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":397,"endLine":397},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":448,"endLine":448},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":467,"endLine":467},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":474,"endLine":474},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":520,"endLine":520},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":529,"endLine":529},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":547,"endLine":547},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":560,"endLine":560},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":601,"endLine":601},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":614,"endLine":614},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":693,"endLine":693},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":699,"endLine":699},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":718,"endLine":718},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":730,"endLine":730},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":734,"endLine":734},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":827,"endLine":827},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":844,"endLine":844},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":848,"endLine":848},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":962,"endLine":962},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":981,"endLine":981},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":1060,"endLine":1060},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":1064,"endLine":1064},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/crm/screens/crm_dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":1070,"endLine":1070},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":87,"endLine":87},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":188,"endLine":188},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":197,"endLine":197},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":310,"endLine":310},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":411,"endLine":411},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":422,"endLine":422},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":436,"endLine":436},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":510,"endLine":510},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":544,"endLine":544},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":601,"endLine":601},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":611,"endLine":611},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":637,"endLine":637},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":675,"endLine":675},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":703,"endLine":703},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"The values in a const list literal must be constants.\nTry removing the keyword 'const' from the list literal.","severity":"error","startLine":703,"endLine":703},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":709,"endLine":709},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"The values in a const list literal must be constants.\nTry removing the keyword 'const' from the list literal.","severity":"error","startLine":709,"endLine":709},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":715,"endLine":715},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"The values in a const list literal must be constants.\nTry removing the keyword 'const' from the list literal.","severity":"error","startLine":715,"endLine":715},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":721,"endLine":721},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"The values in a const list literal must be constants.\nTry removing the keyword 'const' from the list literal.","severity":"error","startLine":721,"endLine":721},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":744,"endLine":744},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":802,"endLine":802},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":824,"endLine":824},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/dashboard/dashboard_screen.dart","message":"Invalid constant value.","severity":"error","startLine":856,"endLine":856},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":137,"endLine":137},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":251,"endLine":251},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":260,"endLine":260},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":365,"endLine":365},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":455,"endLine":455},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":491,"endLine":491},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":499,"endLine":499},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":525,"endLine":525},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":533,"endLine":533},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":586,"endLine":586},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":595,"endLine":595},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/email_sender/email_sender_screen.dart","message":"Invalid constant value.","severity":"error","startLine":663,"endLine":663},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/changelog/changelog_screen.dart","message":"Invalid constant value.","severity":"error","startLine":60,"endLine":60},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/changelog/changelog_screen.dart","message":"Invalid constant value.","severity":"error","startLine":132,"endLine":132},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/changelog/changelog_screen.dart","message":"Invalid constant value.","severity":"error","startLine":139,"endLine":139},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/changelog/changelog_screen.dart","message":"Invalid constant value.","severity":"error","startLine":149,"endLine":149},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/changelog/changelog_screen.dart","message":"Invalid constant value.","severity":"error","startLine":154,"endLine":154},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"Invalid constant value.","severity":"error","startLine":38,"endLine":38},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"Invalid constant value.","severity":"error","startLine":60,"endLine":60},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"Invalid constant value.","severity":"error","startLine":64,"endLine":64},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"Invalid constant value.","severity":"error","startLine":82,"endLine":82},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"Invalid constant value.","severity":"error","startLine":123,"endLine":123},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"Invalid constant value.","severity":"error","startLine":133,"endLine":133},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"The default value of an optional parameter must be constant.","severity":"error","startLine":160,"endLine":160},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/projects/projects_screen.dart","message":"Invalid constant value.","severity":"error","startLine":164,"endLine":164},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":88,"endLine":88},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":105,"endLine":105},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":116,"endLine":116},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":126,"endLine":126},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":197,"endLine":197},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":207,"endLine":207},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":251,"endLine":251},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/settings/settings_screen.dart","message":"Invalid constant value.","severity":"error","startLine":255,"endLine":255},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/shell/app_shell.dart","message":"Invalid constant value.","severity":"error","startLine":263,"endLine":263},
  {"path":"/Users/erikbabcan/.gemini/antigravity-ide/scratch/centralny-dashboard-flutter/lib/features/shell/app_shell.dart","message":"Invalid constant value.","severity":"error","startLine":274,"endLine":274}
]

def fix_file_errors(file_path, line_numbers):
    if not os.path.exists(file_path):
        print(f"File {file_path} not found.")
        return
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
        
    modified = False
    # Sort line numbers in descending order to avoid line shift issues if any (though we don't change line counts)
    sorted_lines = sorted(list(set(line_numbers)), reverse=True)
    
    for l_num in sorted_lines:
        idx = l_num - 1
        if idx >= len(lines):
            continue
            
        # Scan upwards from idx to find the nearest "const"
        scan_idx = idx
        found = False
        while scan_idx >= 0 and scan_idx > idx - 30: # limit scan back to 30 lines
            line_content = lines[scan_idx]
            if 'const ' in line_content:
                # Replace first occurrence of "const " with ""
                lines[scan_idx] = line_content.replace('const ', '', 1)
                print(f"Fixed const in {os.path.basename(file_path)} on line {scan_idx + 1}")
                found = True
                modified = True
                break
            elif 'const[' in line_content or 'const (' in line_content:
                lines[scan_idx] = line_content.replace('const', '', 1)
                print(f"Fixed const in {os.path.basename(file_path)} on line {scan_idx + 1}")
                found = True
                modified = True
                break
            scan_idx -= 1
            
        if not found:
            # If we didn't find const scanning back, let's try to look if there's const on the error line itself
            line_content = lines[idx]
            if 'const' in line_content:
                lines[idx] = line_content.replace('const ', '', 1).replace('const', '', 1)
                print(f"Fixed const directly on line {idx + 1} of {os.path.basename(file_path)}")
                modified = True

    if modified:
        with open(file_path, 'w') as f:
            f.writelines(lines)

def main():
    # Group errors by file path
    grouped = {}
    for err in errors_data:
        if err["severity"] == "error":
            path = err["path"]
            line = err["startLine"]
            if path not in grouped:
                grouped[path] = []
            grouped[path].append(line)
            
    for file_path, lines in grouped.items():
        print(f"Processing {file_path}...")
        fix_file_errors(file_path, lines)

if __name__ == '__main__':
    main()
