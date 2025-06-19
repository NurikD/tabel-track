[33mcommit 954c317f93731a9fcd277ccb6131949b8636b005[m[33m ([m[1;36mHEAD[m[33m)[m
Author: NurikD <duishoev0123@gmail.com>
Date:   Wed Jun 18 09:27:11 2025 +0500

    new design + approve function

[1mdiff --git a/tabelTrack/app/apps.py b/tabelTrack/app/apps.py[m
[1mindex ed327d2..0513cc8 100644[m
[1m--- a/tabelTrack/app/apps.py[m
[1m+++ b/tabelTrack/app/apps.py[m
[36m@@ -4,3 +4,18 @@[m [mfrom django.apps import AppConfig[m
 class AppConfig(AppConfig):[m
     default_auto_field = 'django.db.models.BigAutoField'[m
     name = 'app'[m
[32m+[m
[32m+[m
[32m+[m[32mfrom django.test import TestCase[m
[32m+[m[32mfrom .models import Request[m
[32m+[m[32mfrom django.core.exceptions import ValidationError[m
[32m+[m
[32m+[m[32mclass RequestModelTest(TestCase):[m
[32m+[m[32m    def test_invalid_date_range(self):[m
[32m+[m[32m        with self.assertRaises(ValidationError):[m
[32m+[m[32m            Request.objects.create([m
[32m+[m[32m                user_id=1,[m
[32m+[m[32m                type='отпуск',[m
[32m+[m[32m                start_date='2025-06-15',[m
[32m+[m[32m                end_date='2025-06-10'  # Ошибка: дата окончания раньше начала[m
[32m+[m[32m            ).full_clean()[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/static/css/approve_request.css b/tabelTrack/app/static/css/approve_request.css[m
[1mnew file mode 100644[m
[1mindex 0000000..ddc9319[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/static/css/approve_request.css[m
[36m@@ -0,0 +1,188 @@[m
[32m+[m[32m:root {[m
[32m+[m[32m    --rt-red: #E31E24;[m
[32m+[m[32m    --rt-blue: #1E3A8A;[m
[32m+[m[32m    --rt-green: #10B981;[m
[32m+[m[32m    --rt-yellow: #F59E0B;[m
[32m+[m[32m    --rt-indigo: #6366F1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-white {[m
[32m+[m[32m    background-color: #ffffff;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-gray-100 {[m
[32m+[m[32m    background-color: #f7fafc;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-gray-50 {[m
[32m+[m[32m    background-color: #f9fafb;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-yellow-50 {[m
[32m+[m[32m    background-color: #fefcbf;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-yellow-400 {[m
[32m+[m[32m    background-color: var(--rt-yellow);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-green-50 {[m
[32m+[m[32m    background-color: #d1fae5;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-green-400 {[m
[32m+[m[32m    background-color: #34d399;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-red-50 {[m
[32m+[m[32m    background-color: #fee2e2;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-red-400 {[m
[32m+[m[32m    background-color: #f87171;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-indigo-600 {[m
[32m+[m[32m    background-color: var(--rt-indigo);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-green-600 {[m
[32m+[m[32m    background-color: #059669;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-red-600 {[m
[32m+[m[32m    background-color: var(--rt-red);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-gray-500 {[m
[32m+[m[32m    color: #a3bffa;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-gray-600 {[m
[32m+[m[32m    color: #4a5568;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-gray-700 {[m
[32m+[m[32m    color: #2d3748;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-gray-800 {[m
[32m+[m[32m    color: #1a202c;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-yellow-600 {[m
[32m+[m[32m    color: var(--rt-yellow);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-green-600 {[m
[32m+[m[32m    color: var(--rt-green);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-red-600 {[m
[32m+[m[32m    color: var(--rt-red);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-indigo-600 {[m
[32m+[m[32m    color: var(--rt-indigo);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-white {[m
[32m+[m[32m    color: #ffffff;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.shadow {[m
[32m+[m[32m    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.shadow-lg {[m
[32m+[m[32m    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 1px 3px rgba(0, 0, 0, 0.08);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.hover\:shadow-xl:hover {[m
[32m+[m[32m    box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.hover\:bg-indigo-700:hover {[m
[32m+[m[32m    background-color: #4f46e5;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.hover\:bg-green-700:hover {[m
[32m+[m[32m    background-color: #047857;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.hover\:bg-red-700:hover {[m
[32m+[m[32m    background-color: #dc2626;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.transition {[m
[32m+[m[32m    transition: all 0.2s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rounded {[m
[32m+[m[32m    border-radius: 0.25rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rounded-lg {[m
[32m+[m[32m    border-radius: 0.5rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.px-3 {[m
[32m+[m[32m    padding-left: 0.75rem;[m
[32m+[m[32m    padding-right: 0.75rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.py-2 {[m
[32m+[m[32m    padding-top: 0.5rem;[m
[32m+[m[32m    padding-bottom: 0.5rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.px-4 {[m
[32m+[m[32m    padding-left: 1rem;[m
[32m+[m[32m    padding-right: 1rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.py-4 {[m
[32m+[m[32m    padding-top: 1rem;[m
[32m+[m[32m    padding-bottom: 1rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-sm {[m
[32m+[m[32m    font-size: 0.875rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-lg {[m
[32m+[m[32m    font-size: 1.125rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-2xl {[m
[32m+[m[32m    font-size: 1.5rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-3xl {[m
[32m+[m[32m    font-size: 1.875rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.font-semibold {[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.border {[m
[32m+[m[32m    border-width: 1px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.border-l-4 {[m
[32m+[m[32m    border-left-width: 4px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.w-13 {[m
[32m+[m[32m    width: 33.333333%;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.focus\:ring-2:focus {[m
[32m+[m[32m    outline: none;[m
[32m+[m[32m    box-shadow: 0 0 0 2px rgba(220, 38, 38, 0.5);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.border-gray-300 {[m
[32m+[m[32m    border-color: #e2e8f0;[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/static/css/base.css b/tabelTrack/app/static/css/base.css[m
[1mnew file mode 100644[m
[1mindex 0000000..85701c9[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/static/css/base.css[m
[36m@@ -0,0 +1,125 @@[m
[32m+[m[32m@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');[m
[32m+[m
[32m+[m[32m:root {[m
[32m+[m[32m    --rt-red: #E31E24;[m
[32m+[m[32m    --rt-red-dark: #C21E25;[m
[32m+[m[32m    --rt-navy: #0F172A;[m
[32m+[m[32m    --rt-blue-dark: #1E293B;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m* {[m
[32m+[m[32m    font-family: 'Inter', sans-serif;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar {[m
[32m+[m[32m    background: linear-gradient(180deg, var(--rt-navy) 0%, var(--rt-blue-dark) 100%);[m
[32m+[m[32m    border-right: 2px solid rgba(30, 58, 138, 0.3);[m
[32m+[m[32m    box-shadow: 4px 0 20px rgba(0, 0, 0, 0.15);[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m    z-index: 100;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-item {[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    margin: 4px 8px;[m
[32m+[m[32m    color: #CBD5E1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-item:hover {[m
[32m+[m[32m    background: rgba(30, 58, 138, 0.3);[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    transform: translateX(4px);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-item.active {[m
[32m+[m[32m    background: linear-gradient(90deg, var(--rt-red) 0%, rgba(227, 30, 36, 0.8) 100%);[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    box-shadow: 0 2px 4px rgba(227, 30, 36, 0.3);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-collapsed {[m
[32m+[m[32m    width: 70px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-toggle {[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    top: 20px;[m
[32m+[m[32m    right: -12px;[m
[32m+[m[32m    width: 24px;[m
[32m+[m[32m    height: 24px;[m
[32m+[m[32m    background: linear-gradient(135deg, var(--rt-red) 0%, var(--rt-red-dark) 100%);[m
[32m+[m[32m    border-radius: 50%;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    cursor: pointer;[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m    z-index: 1000;[m
[32m+[m[32m    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-toggle:hover {[m
[32m+[m[32m    background: linear-gradient(135deg, var(--rt-red-dark) 0%, #B91C1C 100%);[m
[32m+[m[32m    transform: scale(1.1);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-toggle i {[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    font-size: 10px;[m
[32m+[m[32m    transition: transform 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-collapsed .sidebar-toggle i {[m
[32m+[m[32m    transform: rotate(180deg);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-section-title {[m
[32m+[m[32m    color: #94A3B8;[m
[32m+[m[32m    font-size: 11px;[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    text-transform: uppercase;[m
[32m+[m[32m    letter-spacing: 0.5px;[m
[32m+[m[32m    margin: 24px 12px 12px;[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.sidebar-section-title::after {[m
[32m+[m[32m    content: '';[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    bottom: -4px;[m
[32m+[m[32m    left: 0;[m
[32m+[m[32m    width: 20px;[m
[32m+[m[32m    height: 1px;[m
[32m+[m[32m    background: #475569;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-logo {[m
[32m+[m[32m    background: linear-gradient(135deg, var(--rt-red) 0%, var(--rt-red-dark) 100%);[m
[32m+[m[32m    color: white;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-card {[m
[32m+[m[32m    background: linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(51, 65, 85, 0.9) 100%);[m
[32m+[m[32m    backdrop-filter: blur(15px);[m
[32m+[m[32m    border: 1px solid rgba(226, 232, 240, 0.15);[m
[32m+[m[32m    box-shadow: 0 12px 40px rgba(15, 23, 42, 0.18), 0 4px 12px rgba(0, 0, 0, 0.12);[m
[32m+[m[32m    transition: all 0.4s ease;[m
[32m+[m[32m    color: #E2E8F0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-badge {[m
[32m+[m[32m    display: inline-flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    min-width: 28px;[m
[32m+[m[32m    height: 28px;[m
[32m+[m[32m    background: linear-gradient(135deg, var(--rt-red) 0%, var(--rt-red-dark) 100%);[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    border-radius: 14px;[m
[32m+[m[32m    font-size: 12px;[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    margin-left: auto;[m
[32m+[m[32m    box-shadow: 0 3px 8px rgba(227, 30, 36, 0.25);[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/static/css/dashboard.css b/tabelTrack/app/static/css/dashboard.css[m
[1mnew file mode 100644[m
[1mindex 0000000..3b1d78b[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/static/css/dashboard.css[m
[36m@@ -0,0 +1,280 @@[m
[32m+[m[32m:root {[m
[32m+[m[32m    --rt-blue: #1E3A8A;[m
[32m+[m[32m    --rt-blue-light: #3B82F6;[m
[32m+[m[32m    --rt-success: #10B981;[m
[32m+[m[32m    --rt-warning: #F59E0B;[m
[32m+[m[32m    --rt-error: #EF4444;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-header {[m
[32m+[m[32m    background: rgba(255, 255, 255, 0.8);[m
[32m+[m[32m    backdrop-filter: blur(20px);[m
[32m+[m[32m    border: 1px solid rgba(226, 232, 240, 0.3);[m
[32m+[m[32m    border-radius: 20px;[m
[32m+[m[32m    padding: 36px;[m
[32m+[m[32m    margin-bottom: 36px;[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 12px 48px rgba(15, 23, 42, 0.06),[m
[32m+[m[32m        0 4px 16px rgba(0, 0, 0, 0.04),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.4);[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    z-index: 10;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.notification-card {[m
[32m+[m[32m    background: rgba(239, 246, 255, 0.8);[m
[32m+[m[32m    backdrop-filter: blur(20px);[m
[32m+[m[32m    border: 1px solid rgba(59, 130, 246, 0.2);[m
[32m+[m[32m    border-left: 4px solid var(--rt-blue);[m
[32m+[m[32m    border-radius: 16px;[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 8px 32px rgba(59, 130, 246, 0.06),[m
[32m+[m[32m        0 2px 8px rgba(0, 0, 0, 0.03),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.4);[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    z-index: 10;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-quick-action {[m
[32m+[m[32m    background: rgba(255, 255, 255, 0.75);[m
[32m+[m[32m    backdrop-filter: blur(20px);[m
[32m+[m[32m    border: 1px solid rgba(226, 232, 240, 0.3);[m
[32m+[m[32m    border-radius: 20px;[m
[32m+[m[32m    padding: 32px;[m
[32m+[m[32m    text-align: center;[m
[32m+[m[32m    transition: all 0.4s ease;[m
[32m+[m[32m    cursor: pointer;[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    overflow: hidden;[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 6px 24px rgba(15, 23, 42, 0.04),[m
[32m+[m[32m        0 2px 8px rgba(0, 0, 0, 0.03),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.3);[m
[32m+[m[32m    z-index: 10;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-quick-action::before {[m
[32m+[m[32m    content: '';[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    top: 0;[m
[32m+[m[32m    left: -100%;[m
[32m+[m[32m    width: 100%;[m
[32m+[m[32m    height: 100%;[m
[32m+[m[32m    background: linear-gradient(90deg, transparent 0%, rgba(227, 30, 36, 0.03) 50%, transparent 100%);[m
[32m+[m[32m    transition: left 0.6s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-quick-action:hover::before {[m
[32m+[m[32m    left: 100%;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-quick-action:hover {[m
[32m+[m[32m    background: rgba(255, 255, 255, 0.9);[m
[32m+[m[32m    border-color: rgba(227, 30, 36, 0.2);[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 12px 36px rgba(227, 30, 36, 0.08),[m
[32m+[m[32m        0 4px 16px rgba(0, 0, 0, 0.06),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.5);[m
[32m+[m[32m    transform: translateY(-8px);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-quick-action i {[m
[32m+[m[32m    color: var(--rt-red);[m
[32m+[m[32m    margin-bottom: 20px;[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-quick-action:hover i {[m
[32m+[m[32m    transform: scale(1.15);[m
[32m+[m[32m    color: var(--rt-red-dark);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-card {[m
[32m+[m[32m    background: rgba(255, 255, 255, 0.75);[m
[32m+[m[32m    backdrop-filter: blur(20px);[m
[32m+[m[32m    border: 1px solid rgba(226, 232, 240, 0.3);[m
[32m+[m[32m    border-radius: 20px;[m
[32m+[m[32m    padding: 32px;[m
[32m+[m[32m    text-align: center;[m
[32m+[m[32m    transition: all 0.4s ease;[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    overflow: hidden;[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 8px 32px rgba(15, 23, 42, 0.06),[m
[32m+[m[32m        0 2px 8px rgba(0, 0, 0, 0.04),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.4);[m
[32m+[m[32m    z-index: 10;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-card::before {[m
[32m+[m[32m    content: '';[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    top: 0;[m
[32m+[m[32m    left: 0;[m
[32m+[m[32m    right: 0;[m
[32m+[m[32m    height: 4px;[m
[32m+[m[32m    background: linear-gradient(90deg, var(--rt-red) 0%, var(--rt-blue) 100%);[m
[32m+[m[32m    border-radius: 20px 20px 0 0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-card:hover {[m
[32m+[m[32m    background: rgba(255, 255, 255, 0.9);[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 16px 48px rgba(15, 23, 42, 0.1),[m
[32m+[m[32m        0 4px 16px rgba(0, 0, 0, 0.06),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.6);[m
[32m+[m[32m    transform: translateY(-8px);[m
[32m+[m[32m    border-color: rgba(226, 232, 240, 0.5);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-icon {[m
[32m+[m[32m    width: 72px;[m
[32m+[m[32m    height: 72px;[m
[32m+[m[32m    border-radius: 20px;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    margin: 0 auto 24px;[m
[32m+[m[32m    background: linear-gradient(135deg, rgba(239, 68, 68, 0.08) 0%, rgba(220, 38, 38, 0.12) 100%);[m
[32m+[m[32m    color: var(--rt-red);[m
[32m+[m[32m    font-size: 32px;[m
[32m+[m[32m    box-shadow: 0 8px 24px rgba(239, 68, 68, 0.08);[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-icon.blue {[m
[32m+[m[32m    background: linear-gradient(135deg, rgba(59, 130, 246, 0.08) 0%, rgba(30, 58, 138, 0.12) 100%);[m
[32m+[m[32m    color: var(--rt-blue);[m
[32m+[m[32m    box-shadow: 0 8px 24px rgba(59, 130, 246, 0.08);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-icon.green {[m
[32m+[m[32m    background: linear-gradient(135deg, rgba(16, 185, 129, 0.08) 0%, rgba(5, 150, 105, 0.12) 100%);[m
[32m+[m[32m    color: var(--rt-success);[m
[32m+[m[32m    box-shadow: 0 8px 24px rgba(16, 185, 129, 0.08);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-icon.yellow {[m
[32m+[m[32m    background: linear-gradient(135deg, rgba(245, 158, 11, 0.08) 0%, rgba(217, 119, 6, 0.12) 100%);[m
[32m+[m[32m    color: var(--rt-warning);[m
[32m+[m[32m    box-shadow: 0 8px 24px rgba(245, 158, 11, 0.08);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-stat-card:hover .rt-stat-icon {[m
[32m+[m[32m    transform: scale(1.05);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-progress {[m
[32m+[m[32m    background: rgba(226, 232, 240, 0.4);[m
[32m+[m[32m    height: 8px;[m
[32m+[m[32m    border-radius: 6px;[m
[32m+[m[32m    overflow: hidden;[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.04);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-progress-bar {[m
[32m+[m[32m    background: linear-gradient(90deg, var(--rt-red) 0%, var(--rt-blue) 100%);[m
[32m+[m[32m    height: 100%;[m
[32m+[m[32m    border-radius: 6px;[m
[32m+[m[32m    transition: width 0.5s ease;[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    box-shadow: 0 2px 8px rgba(227, 30, 36, 0.15);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-progress-bar::after {[m
[32m+[m[32m    content: '';[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    top: 0;[m
[32m+[m[32m    left: 0;[m
[32m+[m[32m    right: 0;[m
[32m+[m[32m    bottom: 0;[m
[32m+[m[32m    background: linear-gradient(90deg, transparent 0%, rgba(255,255,255,0.4) 50%, transparent 100%);[m
[32m+[m[32m    animation: shimmer 2s infinite;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m@keyframes shimmer {[m
[32m+[m[32m    0% { transform: translateX(-100%); }[m
[32m+[m[32m    100% { transform: translateX(100%); }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-request-card {[m
[32m+[m[32m    background: rgba(255, 255, 255, 0.75);[m
[32m+[m[32m    backdrop-filter: blur(20px);[m
[32m+[m[32m    border: 1px solid rgba(226, 232, 240, 0.3);[m
[32m+[m[32m    border-radius: 16px;[m
[32m+[m[32m    padding: 28px;[m
[32m+[m[32m    margin-bottom: 20px;[m
[32m+[m[32m    transition: all 0.4s ease;[m
[32m+[m[32m    border-left: 4px solid transparent;[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 6px 24px rgba(15, 23, 42, 0.04),[m
[32m+[m[32m        0 2px 8px rgba(0, 0, 0, 0.03),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.3);[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    z-index: 10;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-request-card:hover {[m
[32m+[m[32m    background: rgba(255, 255, 255, 0.9);[m
[32m+[m[32m    box-shadow:[m
[32m+[m[32m        0 12px 36px rgba(15, 23, 42, 0.08),[m
[32m+[m[32m        0 4px 16px rgba(0, 0, 0, 0.06),[m
[32m+[m[32m        inset 0 1px 0 rgba(255, 255, 255, 0.5);[m
[32m+[m[32m    transform: translateX(8px);[m
[32m+[m[32m    border-color: rgba(226, 232, 240, 0.5);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-request-card.pending {[m
[32m+[m[32m    border-left-color: var(--rt-warning);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-request-card.approved {[m
[32m+[m[32m    border-left-color: var(--rt-success);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-request-card.rejected {[m
[32m+[m[32m    border-left-color: var(--rt-error);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-section-title {[m
[32m+[m[32m    color: var(--rt-navy);[m
[32m+[m[32m    font-size: 1.5rem;[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    margin-bottom: 28px;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-section-title::after {[m
[32m+[m[32m    content: '';[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    bottom: -12px;[m
[32m+[m[32m    left: 40px;[m
[32m+[m[32m    width: 60px;[m
[32m+[m[32m    height: 4px;[m
[32m+[m[32m    background: linear-gradient(90deg, var(--rt-red) 0%, var(--rt-blue) 100%);[m
[32m+[m[32m    border-radius: 2px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rt-section-title i {[m
[32m+[m[32m    color: var(--rt-red);[m
[32m+[m[32m    margin-right: 16px;[m
[32m+[m[32m    font-size: 1.25rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.status-indicator {[m
[32m+[m[32m    width: 12px;[m
[32m+[m[32m    height: 12px;[m
[32m+[m[32m    border-radius: 50%;[m
[32m+[m[32m    background: var(--rt-success);[m
[32m+[m[32m    display: inline-block;[m
[32m+[m[32m    animation: pulse 2s infinite;[m
[32m+[m[32m    box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.2);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m@keyframes pulse {[m
[32m+[m[32m    0%, 100% { opacity: 1; transform: scale(1); }[m
[32m+[m[32m    50% { opacity: 0.8; transform: scale(1.15); }[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/static/css/leave_request.css b/tabelTrack/app/static/css/leave_request.css[m
[1mnew file mode 100644[m
[1mindex 0000000..2b1ed57[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/static/css/leave_request.css[m
[36m@@ -0,0 +1,147 @@[m
[32m+[m[32m:root {[m
[32m+[m[32m    --rt-red: #E31E24;[m
[32m+[m[32m    --rt-blue: #1E3A8A;[m
[32m+[m[32m    --rt-green: #10B981;[m
[32m+[m[32m    --rt-yellow: #F59E0B;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-white {[m
[32m+[m[32m    background-color: #ffffff;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-gray-100 {[m
[32m+[m[32m    background-color: #f7fafc;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-red-600 {[m
[32m+[m[32m    background-color: var(--rt-red);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-blue-100 {[m
[32m+[m[32m    background-color: #ebf8ff;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-blue-600 {[m
[32m+[m[32m    background-color: var(--rt-blue);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-green-500 {[m
[32m+[m[32m    background-color: var(--rt-green);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-yellow-100 {[m
[32m+[m[32m    background-color: #fefcbf;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.bg-red-100 {[m
[32m+[m[32m    background-color: #fee2e2;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-red-600 {[m
[32m+[m[32m    color: var(--rt-red);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-blue-600 {[m
[32m+[m[32m    color: var(--rt-blue);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-green-600 {[m
[32m+[m[32m    color: var(--rt-green);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-yellow-600 {[m
[32m+[m[32m    color: var(--rt-yellow);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-gray-600 {[m
[32m+[m[32m    color: #4a5568;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-gray-700 {[m
[32m+[m[32m    color: #2d3748;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-gray-900 {[m
[32m+[m[32m    color: #1a202c;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.shadow {[m
[32m+[m[32m    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.hover\:bg-gray-50:hover {[m
[32m+[m[32m    background-color: #f9fafb;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.hover\:bg-gray-300:hover {[m
[32m+[m[32m    background-color: #e2e8f0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.hover\:bg-green-600:hover {[m
[32m+[m[32m    background-color: #059669;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.focus\:ring-2:focus {[m
[32m+[m[32m    outline: none;[m
[32m+[m[32m    box-shadow: 0 0 0 2px rgba(220, 38, 38, 0.5);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.w-10 {[m
[32m+[m[32m    width: 2.5rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.h-10 {[m
[32m+[m[32m    height: 2.5rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.w-12 {[m
[32m+[m[32m    width: 3rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.h-12 {[m
[32m+[m[32m    height: 3rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rounded-lg {[m
[32m+[m[32m    border-radius: 0.5rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.rounded {[m
[32m+[m[32m    border-radius: 0.25rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.px-3 {[m
[32m+[m[32m    padding-left: 0.75rem;[m
[32m+[m[32m    padding-right: 0.75rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.py-2 {[m
[32m+[m[32m    padding-top: 0.5rem;[m
[32m+[m[32m    padding-bottom: 0.5rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.px-4 {[m
[32m+[m[32m    padding-left: 1rem;[m
[32m+[m[32m    padding-right: 1rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.py-1 {[m
[32m+[m[32m    padding-top: 0.25rem;[m
[32m+[m[32m    padding-bottom: 0.25rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-sm {[m
[32m+[m[32m    font-size: 0.875rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.text-lg {[m
[32m+[m[32m    font-size: 1.125rem;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.font-bold {[m
[32m+[m[32m    font-weight: 700;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.font-medium {[m
[32m+[m[32m    font-weight: 500;[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/static/css/profile.css b/tabelTrack/app/static/css/profile.css[m
[1mnew file mode 100644[m
[1mindex 0000000..406bc5b[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/static/css/profile.css[m
[36m@@ -0,0 +1,497 @@[m
[32m+[m[32m/* Profile Page Styles */[m
[32m+[m[32m.profile-container {[m
[32m+[m[32m    padding: 24px;[m
[32m+[m[32m    background-color: #f5f6fa;[m
[32m+[m[32m    min-height: 100vh;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Header Section */[m
[32m+[m[32m.profile-header {[m
[32m+[m[32m    background: white;[m
[32m+[m[32m    border-radius: 12px;[m
[32m+[m[32m    padding: 24px;[m
[32m+[m[32m    margin-bottom: 24px;[m
[32m+[m[32m    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.profile-greeting {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: space-between;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.greeting-icon {[m
[32m+[m[32m    width: 60px;[m
[32m+[m[32m    height: 60px;[m
[32m+[m[32m    background: linear-gradient(135deg, #d32f2f, #f44336);[m
[32m+[m[32m    border-radius: 12px;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    font-size: 24px;[m
[32m+[m[32m    margin-right: 20px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.greeting-content h1 {[m
[32m+[m[32m    font-size: 32px;[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    margin: 0 0 8px 0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.profile-status {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    gap: 12px;[m
[32m+[m[32m    color: #7f8c8d;[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.status-indicator {[m
[32m+[m[32m    width: 8px;[m
[32m+[m[32m    height: 8px;[m
[32m+[m[32m    border-radius: 50%;[m
[32m+[m[32m    background-color: #27ae60;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.status-indicator.online {[m
[32m+[m[32m    background-color: #27ae60;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.status-indicator.offline {[m
[32m+[m[32m    background-color: #e74c3c;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.btn-edit {[m
[32m+[m[32m    background: #d32f2f;[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    border: none;[m
[32m+[m[32m    padding: 12px 24px;[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m    font-weight: 500;[m
[32m+[m[32m    cursor: pointer;[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.btn-edit:hover {[m
[32m+[m[32m    background: #b71c1c;[m
[32m+[m[32m    transform: translateY(-2px);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Info Cards Grid */[m
[32m+[m[32m.profile-info-grid {[m
[32m+[m[32m    display: grid;[m
[32m+[m[32m    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));[m
[32m+[m[32m    gap: 24px;[m
[32m+[m[32m    margin-bottom: 32px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.info-card {[m
[32m+[m[32m    background: white;[m
[32m+[m[32m    border-radius: 12px;[m
[32m+[m[32m    padding: 24px;[m
[32m+[m[32m    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.info-card:hover {[m
[32m+[m[32m    transform: translateY(-4px);[m
[32m+[m[32m    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.info-card.full-width {[m
[32m+[m[32m    grid-column: 1 / -1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.card-header {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: space-between;[m
[32m+[m[32m    margin-bottom: 20px;[m
[32m+[m[32m    padding-bottom: 16px;[m
[32m+[m[32m    border-bottom: 2px solid #ecf0f1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.card-header h3 {[m
[32m+[m[32m    font-size: 18px;[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    margin: 0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.card-icon {[m
[32m+[m[32m    width: 40px;[m
[32m+[m[32m    height: 40px;[m
[32m+[m[32m    background: linear-gradient(135deg, #d32f2f, #f44336);[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    font-size: 16px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Profile Avatar */[m
[32m+[m[32m.profile-avatar {[m
[32m+[m[32m    position: relative;[m
[32m+[m[32m    width: 120px;[m
[32m+[m[32m    height: 120px;[m
[32m+[m[32m    margin: 0 auto 20px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.profile-avatar img {[m
[32m+[m[32m    width: 100%;[m
[32m+[m[32m    height: 100%;[m
[32m+[m[32m    border-radius: 50%;[m
[32m+[m[32m    object-fit: cover;[m
[32m+[m[32m    border: 4px solid #ecf0f1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.avatar-status {[m
[32m+[m[32m    position: absolute;[m
[32m+[m[32m    bottom: 8px;[m
[32m+[m[32m    right: 8px;[m
[32m+[m[32m    width: 24px;[m
[32m+[m[32m    height: 24px;[m
[32m+[m[32m    border-radius: 50%;[m
[32m+[m[32m    border: 3px solid white;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.avatar-status.online {[m
[32m+[m[32m    background-color: #27ae60;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.avatar-status.offline {[m
[32m+[m[32m    background-color: #e74c3c;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Detail Rows */[m
[32m+[m[32m.detail-row {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    justify-content: space-between;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    padding: 12px 0;[m
[32m+[m[32m    border-bottom: 1px solid #ecf0f1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.detail-row:last-child {[m
[32m+[m[32m    border-bottom: none;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.detail-row .label {[m
[32m+[m[32m    font-weight: 500;[m
[32m+[m[32m    color: #7f8c8d;[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.detail-row .value {[m
[32m+[m[32m    font-weight: 500;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m    text-align: right;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Work Statistics */[m
[32m+[m[32m.stats-grid {[m
[32m+[m[32m    display: grid;[m
[32m+[m[32m    grid-template-columns: repeat(2, 1fr);[m
[32m+[m[32m    gap: 20px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-item {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    gap: 16px;[m
[32m+[m[32m    padding: 16px;[m
[32m+[m[32m    background: #f8f9fa;[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-item:hover {[m
[32m+[m[32m    background: #e9ecef;[m
[32m+[m[32m    transform: scale(1.02);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-icon {[m
[32m+[m[32m    width: 48px;[m
[32m+[m[32m    height: 48px;[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    font-size: 20px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-icon.work-days {[m
[32m+[m[32m    background: linear-gradient(135deg, #e74c3c, #c0392b);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-icon.work-hours {[m
[32m+[m[32m    background: linear-gradient(135deg, #3498db, #2980b9);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-icon.vacation-days {[m
[32m+[m[32m    background: linear-gradient(135deg, #f39c12, #e67e22);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-icon.active-requests {[m
[32m+[m[32m    background: linear-gradient(135deg, #9b59b6, #8e44ad);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-content {[m
[32m+[m[32m    flex: 1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-number {[m
[32m+[m[32m    font-size: 24px;[m
[32m+[m[32m    font-weight: 700;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    line-height: 1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-label {[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m    font-weight: 500;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    margin: 4px 0 2px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.stat-subtitle {[m
[32m+[m[32m    font-size: 12px;[m
[32m+[m[32m    color: #7f8c8d;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Manager Info */[m
[32m+[m[32m.manager-info {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    gap: 20px;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.manager-avatar {[m
[32m+[m[32m    width: 80px;[m
[32m+[m[32m    height: 80px;[m
[32m+[m[32m    flex-shrink: 0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.manager-avatar img {[m
[32m+[m[32m    width: 100%;[m
[32m+[m[32m    height: 100%;[m
[32m+[m[32m    border-radius: 50%;[m
[32m+[m[32m    object-fit: cover;[m
[32m+[m[32m    border: 3px solid #ecf0f1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.manager-details {[m
[32m+[m[32m    flex: 1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Activity List */[m
[32m+[m[32m.activity-list {[m
[32m+[m[32m    max-height: 400px;[m
[32m+[m[32m    overflow-y: auto;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-item {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: flex-start;[m
[32m+[m[32m    gap: 16px;[m
[32m+[m[32m    padding: 16px 0;[m
[32m+[m[32m    border-bottom: 1px solid #ecf0f1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-item:last-child {[m
[32m+[m[32m    border-bottom: none;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-icon {[m
[32m+[m[32m    width: 40px;[m
[32m+[m[32m    height: 40px;[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    font-size: 16px;[m
[32m+[m[32m    flex-shrink: 0;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-icon.work {[m
[32m+[m[32m    background: linear-gradient(135deg, #27ae60, #2ecc71);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-icon.vacation {[m
[32m+[m[32m    background: linear-gradient(135deg, #f39c12, #e67e22);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-icon.request {[m
[32m+[m[32m    background: linear-gradient(135deg, #3498db, #2980b9);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-icon.system {[m
[32m+[m[32m    background: linear-gradient(135deg, #9b59b6, #8e44ad);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-content {[m
[32m+[m[32m    flex: 1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-title {[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m    margin-bottom: 4px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-description {[m
[32m+[m[32m    color: #7f8c8d;[m
[32m+[m[32m    font-size: 13px;[m
[32m+[m[32m    margin-bottom: 4px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.activity-time {[m
[32m+[m[32m    color: #95a5a6;[m
[32m+[m[32m    font-size: 12px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.no-activity {[m
[32m+[m[32m    text-align: center;[m
[32m+[m[32m    padding: 40px;[m
[32m+[m[32m    color: #7f8c8d;[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.no-activity i {[m
[32m+[m[32m    display: block;[m
[32m+[m[32m    font-size: 48px;[m
[32m+[m[32m    margin-bottom: 12px;[m
[32m+[m[32m    opacity: 0.5;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Quick Actions */[m
[32m+[m[32m.quick-actions {[m
[32m+[m[32m    background: white;[m
[32m+[m[32m    border-radius: 12px;[m
[32m+[m[32m    padding: 24px;[m
[32m+[m[32m    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.quick-actions h3 {[m
[32m+[m[32m    font-size: 18px;[m
[32m+[m[32m    font-weight: 600;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    margin: 0 0 20px 0;[m
[32m+[m[32m    padding-bottom: 16px;[m
[32m+[m[32m    border-bottom: 2px solid #ecf0f1;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.actions-grid {[m
[32m+[m[32m    display: grid;[m
[32m+[m[32m    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));[m
[32m+[m[32m    gap: 16px;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.action-btn {[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    gap: 12px;[m
[32m+[m[32m    padding: 16px;[m
[32m+[m[32m    background: #f8f9fa;[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    text-decoration: none;[m
[32m+[m[32m    color: #2c3e50;[m
[32m+[m[32m    font-weight: 500;[m
[32m+[m[32m    font-size: 14px;[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.action-btn:hover {[m
[32m+[m[32m    background: #d32f2f;[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    transform: translateY(-2px);[m
[32m+[m[32m    box-shadow: 0 4px 12px rgba(211, 47, 47, 0.3);[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.action-icon {[m
[32m+[m[32m    width: 40px;[m
[32m+[m[32m    height: 40px;[m
[32m+[m[32m    background: linear-gradient(135deg, #d32f2f, #f44336);[m
[32m+[m[32m    border-radius: 8px;[m
[32m+[m[32m    display: flex;[m
[32m+[m[32m    align-items: center;[m
[32m+[m[32m    justify-content: center;[m
[32m+[m[32m    color: white;[m
[32m+[m[32m    font-size: 16px;[m
[32m+[m[32m    transition: all 0.3s ease;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.action-btn:hover .action-icon {[m
[32m+[m[32m    background: linear-gradient(135deg, #fff, #f8f9fa);[m
[32m+[m[32m    color: #d32f2f;[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m/* Responsive Design */[m
[32m+[m[32m@media (max-width: 768px) {[m
[32m+[m[32m    .profile-container {[m
[32m+[m[32m        padding: 16px;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .profile-greeting {[m
[32m+[m[32m        flex-direction: column;[m
[32m+[m[32m        align-items: flex-start;[m
[32m+[m[32m        gap: 16px;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .greeting-icon {[m
[32m+[m[32m        margin-right: 0;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .profile-info-grid {[m
[32m+[m[32m        grid-template-columns: 1fr;[m
[32m+[m[32m        gap: 16px;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .stats-grid {[m
[32m+[m[32m        grid-template-columns: 1fr;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .manager-info {[m
[32m+[m[32m        flex-direction: column;[m
[32m+[m[32m        text-align: center;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .actions-grid {[m
[32m+[m[32m        grid-template-columns: 1fr;[m
[32m+[m[32m    }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m@media (max-width: 480px) {[m
[32m+[m[32m    .greeting-content h1 {[m
[32m+[m[32m        font-size: 24px;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .profile-status {[m
[32m+[m[32m        flex-wrap: wrap;[m
[32m+[m[32m        gap: 8px;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .card-header {[m
[32m+[m[32m        flex-direction: column;[m
[32m+[m[32m        align-items: flex-start;[m
[32m+[m[32m        gap: 12px;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .detail-row {[m
[32m+[m[32m        flex-direction: column;[m
[32m+[m[32m        align-items: flex-start;[m
[32m+[m[32m        gap: 4px;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    .detail-row .value {[m
[32m+[m[32m        text-align: left;[m
[32m+[m[32m    }[m
[32m+[m[32m}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/templates/approve_requests.html b/tabelTrack/app/templates/approve_requests.html[m
[1mindex 277363f..64a5b4b 100644[m
[1m--- a/tabelTrack/app/templates/approve_requests.html[m
[1m+++ b/tabelTrack/app/templates/approve_requests.html[m
[36m@@ -2,66 +2,290 @@[m
 {% block title %}Согласование заявок{% endblock %}[m
 [m
 {% block content %}[m
[31m-<div class="max-w-5xl mx-auto p-6">[m
[31m-[m
[31m-  <h2 class="text-2xl font-bold mb-4">📋 Заявки на согласование</h2>[m
[31m-[m
[31m-  <!-- Фильтр по типу -->[m
[31m-  <form method="get" class="mb-4 flex gap-2">[m
[31m-    <select name="type" class="border rounded px-3 py-1">[m
[31m-      <option value="">Все типы</option>[m
[31m-      <option value="vacation" {% if selected_type == "vacation" %}selected{% endif %}>Отпуск</option>[m
[31m-      <option value="sick" {% if selected_type == "sick" %}selected{% endif %}>Больничный</option>[m
[31m-    </select>[m
[31m-    <button class="bg-indigo-600 text-white px-4 py-1 rounded hover:bg-indigo-700">Фильтровать</button>[m
[31m-  </form>[m
[31m-[m
[31m-  <!-- Новые заявки -->[m
[31m-  <div class="mb-6">[m
[31m-    <h3 class="text-lg font-semibold mb-2 text-yellow-600">⏳ В ожидании</h3>[m
[31m-    {% if pending_requests %}[m
[31m-      {% for r in pending_requests %}[m
[31m-        <div class="bg-yellow-100 border rounded p-3 mb-2 flex justify-between items-center">[m
[31m-          <div>[m
[31m-            <p class="font-medium">{{ r.user.get_full_name }} — {{ r.get_leave_type_display }}</p>[m
[31m-            <p class="text-sm text-gray-600">{{ r.start_date }} → {{ r.end_date }}</p>[m
[31m-            {% if r.comment %}<p class="text-sm italic text-gray-700 mt-1">{{ r.comment }}</p>{% endif %}[m
[31m-          </div>[m
[31m-          <form method="post" class="flex gap-2 items-center">{% csrf_token %}[m
[31m-            <input type="hidden" name="request_id" value="{{ r.id }}">[m
[31m-            <button name="action" value="approve" class="bg-green-500 text-white px-3 py-1 rounded">Одобрить</button>[m
[31m-            <button name="action" value="reject" class="bg-red-500 text-white px-3 py-1 rounded">Отклонить</button>[m
[31m-          </form>[m
[32m+[m[32m<div class="container mx-auto px-6 py-6 max-w-7xl">[m
[32m+[m[32m    <!-- Заголовок страницы -->[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <div class="flex items-center gap-3 mb-4">[m
[32m+[m[32m            <div class="w-12 h-12 bg-red-500 rounded-xl flex items-center justify-center">[m
[32m+[m[32m                <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                    <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z"/>[m
[32m+[m[32m                    <path fill-rule="evenodd" d="M4 5a2 2 0 012-2v1a1 1 0 001 1h6a1 1 0 001-1V3a2 2 0 012 2v6.586l2.707 2.707A1 1 0 0118 17v-1a1 1 0 00-1-1h-4a1 1 0 00-1 1v1a1 1 0 01-1 1H9a1 1 0 01-1-1v-1a1 1 0 00-1-1H3a1 1 0 00-1 1v1a1 1 0 00.293.707L4 16.586V5z" clip-rule="evenodd"/>[m
[32m+[m[32m                </svg>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <h1 class="text-2xl font-bold text-gray-900">Заявки на согласование</h1>[m
         </div>[m
[31m-      {% endfor %}[m
[31m-    {% else %}[m
[31m-      <p class="text-sm text-gray-500">Нет новых заявок.</p>[m
[31m-    {% endif %}[m
[31m-  </div>[m
[31m-[m
[31m-  <!-- Одобренные -->[m
[31m-  <div class="mb-6">[m
[31m-    <h3 class="text-lg font-semibold mb-2 text-green-600">✅ Одобрено</h3>[m
[31m-    {% for r in approved_requests %}[m
[31m-      <div class="bg-green-50 border rounded p-2 mb-2 text-sm">[m
[31m-        {{ r.user.get_full_name }} — {{ r.get_leave_type_display }} ({{ r.start_date }} → {{ r.end_date }})[m
[31m-      </div>[m
[31m-    {% empty %}[m
[31m-      <p class="text-sm text-gray-500">Нет.</p>[m
[31m-    {% endfor %}[m
[31m-  </div>[m
[31m-[m
[31m-  <!-- Отклонённые -->[m
[31m-  <div class="mb-6">[m
[31m-    <h3 class="text-lg font-semibold mb-2 text-red-600">❌ Отклонено</h3>[m
[31m-    {% for r in rejected_requests %}[m
[31m-      <div class="bg-red-50 border rounded p-2 mb-2 text-sm">[m
[31m-        {{ r.user.get_full_name }} — {{ r.get_leave_type_display }} ({{ r.start_date }} → {{ r.end_date }})[m
[31m-      </div>[m
[31m-    {% empty %}[m
[31m-      <p class="text-sm text-gray-500">Нет.</p>[m
[31m-    {% endfor %}[m
[31m-  </div>[m
[32m+[m[32m    </div>[m
 [m
[32m+[m[32m    <!-- Фильтр -->[m
[32m+[m[32m    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-8">[m
[32m+[m[32m        <form method="get" class="flex gap-4 items-center">[m
[32m+[m[32m            <div class="flex-1">[m
[32m+[m[32m                <label class="block text-sm font-medium text-gray-700 mb-2">Тип заявки</label>[m
[32m+[m[32m                <select name="type" class="w-full px-4 py-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent bg-gray-50">[m
[32m+[m[32m                    <option value="">Все типы</option>[m
[32m+[m[32m                    <option value="vacation" {% if selected_type == "vacation" %}selected{% endif %}>Отпуск</option>[m
[32m+[m[32m                    <option value="sick" {% if selected_type == "sick" %}selected{% endif %}>Больничный</option>[m
[32m+[m[32m                </select>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div class="flex items-end">[m
[32m+[m[32m                <button class="bg-gradient-to-r from-red-500 to-red-600 text-white px-6 py-3 rounded-xl hover:from-red-600 hover:to-red-700 transition-all duration-200 shadow-lg hover:shadow-xl font-medium">[m
[32m+[m[32m                    Фильтровать[m
[32m+[m[32m                </button>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </form>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <!-- Статистика заявок -->[m
[32m+[m[32m    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">[m
[32m+[m[32m        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">[m
[32m+[m[32m            <div class="flex items-center justify-between">[m
[32m+[m[32m                <div>[m
[32m+[m[32m                    <p class="text-sm font-medium text-gray-600">В ожидании</p>[m
[32m+[m[32m                    <p class="text-2xl font-bold text-orange-600">{{ pending_requests|length }}</p>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center">[m
[32m+[m[32m                    <svg class="w-6 h-6 text-orange-600" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>[m
[32m+[m[32m                    </svg>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">[m
[32m+[m[32m            <div class="flex items-center justify-between">[m
[32m+[m[32m                <div>[m
[32m+[m[32m                    <p class="text-sm font-medium text-gray-600">Одобрено</p>[m
[32m+[m[32m                    <p class="text-2xl font-bold text-green-600">{{ approved_requests|length }}</p>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">[m
[32m+[m[32m                    <svg class="w-6 h-6 text-green-600" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>[m
[32m+[m[32m                    </svg>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">[m
[32m+[m[32m            <div class="flex items-center justify-between">[m
[32m+[m[32m                <div>[m
[32m+[m[32m                    <p class="text-sm font-medium text-gray-600">Отклонено</p>[m
[32m+[m[32m                    <p class="text-2xl font-bold text-red-600">{{ rejected_requests|length }}</p>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center">[m
[32m+[m[32m                    <svg class="w-6 h-6 text-red-600" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>[m
[32m+[m[32m                    </svg>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <!-- Заявки в ожидании -->[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <div class="flex items-center gap-3 mb-6">[m
[32m+[m[32m            <div class="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center">[m
[32m+[m[32m                <svg class="w-4 h-4 text-orange-600" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>[m
[32m+[m[32m                </svg>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <h2 class="text-xl font-bold text-gray-900">В ожидании</h2>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        {% if pending_requests %}[m
[32m+[m[32m            <div class="space-y-4">[m
[32m+[m[32m                {% for r in pending_requests %}[m
[32m+[m[32m                    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition-all duration-200">[m
[32m+[m[32m                        <div class="flex justify-between items-start">[m
[32m+[m[32m                            <div class="flex-1">[m
[32m+[m[32m                                <div class="flex items-center gap-3 mb-3">[m
[32m+[m[32m                                    <div class="w-10 h-10 bg-gradient-to-br from-red-500 to-red-600 rounded-xl flex items-center justify-center text-white font-semibold text-sm">[m
[32m+[m[32m                                        {{ r.user.get_full_name|first }}[m
[32m+[m[32m                                    </div>[m
[32m+[m[32m                                    <div>[m
[32m+[m[32m                                        <h3 class="font-semibold text-gray-900">{{ r.user.get_full_name }}</h3>[m
[32m+[m[32m                                        <p class="text-sm text-gray-500">{{ r.get_leave_type_display }}</p>[m
[32m+[m[32m                                    </div>[m
[32m+[m[32m                                </div>[m
[32m+[m
[32m+[m[32m                                <div class="flex items-center gap-4 text-sm text-gray-600 mb-3">[m
[32m+[m[32m                                    <div class="flex items-center gap-2">[m
[32m+[m[32m                                        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                                            <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"/>[m
[32m+[m[32m                                        </svg>[m
[32m+[m[32m                                        <span>{{ r.start_date|date:"j F Y" }}</span>[m
[32m+[m[32m                                    </div>[m
[32m+[m[32m                                    <span class="text-gray-400">→</span>[m
[32m+[m[32m                                    <div class="flex items-center gap-2">[m
[32m+[m[32m                                        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                                            <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"/>[m
[32m+[m[32m                                        </svg>[m
[32m+[m[32m                                        <span>{{ r.end_date|date:"j F Y" }}</span>[m
[32m+[m[32m                                    </div>[m
[32m+[m[32m                                </div>[m
[32m+[m
[32m+[m[32m                                {% if r.comment %}[m
[32m+[m[32m                                    <div class="bg-gray-50 rounded-xl p-4 mb-4">[m
[32m+[m[32m                                        <p class="text-sm text-gray-700 italic">{{ r.comment }}</p>[m
[32m+[m[32m                                    </div>[m
[32m+[m[32m                                {% endif %}[m
[32m+[m[32m                            </div>[m
[32m+[m
[32m+[m[32m                            <form method="post" class="flex gap-3 ml-6">[m
[32m+[m[32m                                {% csrf_token %}[m
[32m+[m[32m                                <input type="hidden" name="request_id" value="{{ r.id }}">[m
[32m+[m[32m                                <button name="action" value="approve" class="bg-gradient-to-r from-green-500 to-green-600 text-white px-4 py-2 rounded-xl hover:from-green-600 hover:to-green-700 transition-all duration-200 shadow-lg hover:shadow-xl font-medium flex items-center gap-2">[m
[32m+[m[32m                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>[m
[32m+[m[32m                                    </svg>[m
[32m+[m[32m                                    Одобрить[m
[32m+[m[32m                                </button>[m
[32m+[m[32m                                <button name="action" value="reject" class="bg-gradient-to-r from-red-500 to-red-600 text-white px-4 py-2 rounded-xl hover:from-red-600 hover:to-red-700 transition-all duration-200 shadow-lg hover:shadow-xl font-medium flex items-center gap-2">[m
[32m+[m[32m                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                                        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>[m
[32m+[m[32m                                    </svg>[m
[32m+[m[32m                                    Отклонить[m
[32m+[m[32m                                </button>[m
[32m+[m[32m                            </form>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                {% endfor %}[m
[32m+[m[32m            </div>[m
[32m+[m[32m        {% else %}[m
[32m+[m[32m            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 text-center">[m
[32m+[m[32m                <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">[m
[32m+[m[32m                    <svg class="w-8 h-8 text-gray-400" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>[m
[32m+[m[32m                    </svg>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <p class="text-gray-500">Нет новых заявок</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        {% endif %}[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <!-- Одобренные заявки -->[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <div class="flex items-center gap-3 mb-6">[m
[32m+[m[32m            <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">[m
[32m+[m[32m                <svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>[m
[32m+[m[32m                </svg>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <h2 class="text-xl font-bold text-gray-900">Одобрено</h2>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        {% if approved_requests %}[m
[32m+[m[32m            <div class="space-y-4">[m
[32m+[m[32m                {% for r in approved_requests %}[m
[32m+[m[32m                    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">[m
[32m+[m[32m                        <div class="flex items-center gap-3">[m
[32m+[m[32m                            <div class="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-xl flex items-center justify-center text-white font-semibold text-sm">[m
[32m+[m[32m                                {{ r.user.get_full_name|first }}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="flex-1">[m
[32m+[m[32m                                <h3 class="font-semibold text-gray-900">{{ r.user.get_full_name }}</h3>[m
[32m+[m[32m                                <div class="flex items-center gap-4 text-sm text-gray-600 mt-1">[m
[32m+[m[32m                                    <span>{{ r.get_leave_type_display }}</span>[m
[32m+[m[32m                                    <span class="text-gray-400">•</span>[m
[32m+[m[32m                                    <span>{{ r.start_date|date:"j F Y" }} → {{ r.end_date|date:"j F Y" }}</span>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="flex items-center gap-2 px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-medium">[m
[32m+[m[32m                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                                Одобрено[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                {% endfor %}[m
[32m+[m[32m            </div>[m
[32m+[m[32m        {% else %}[m
[32m+[m[32m            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 text-center">[m
[32m+[m[32m                <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">[m
[32m+[m[32m                    <svg class="w-8 h-8 text-gray-400" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>[m
[32m+[m[32m                    </svg>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <p class="text-gray-500">Нет одобренных заявок</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        {% endif %}[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <!-- Отклонённые заявки -->[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <div class="flex items-center gap-3 mb-6">[m
[32m+[m[32m            <div class="w-8 h-8 bg-red-100 rounded-lg flex items-center justify-center">[m
[32m+[m[32m                <svg class="w-4 h-4 text-red-600" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                    <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>[m
[32m+[m[32m                </svg>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <h2 class="text-xl font-bold text-gray-900">Отклонено</h2>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        {% if rejected_requests %}[m
[32m+[m[32m            <div class="space-y-4">[m
[32m+[m[32m                {% for r in rejected_requests %}[m
[32m+[m[32m                    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">[m
[32m+[m[32m                        <div class="flex items-center gap-3">[m
[32m+[m[32m                            <div class="w-10 h-10 bg-gradient-to-br from-red-500 to-red-600 rounded-xl flex items-center justify-center text-white font-semibold text-sm">[m
[32m+[m[32m                                {{ r.user.get_full_name|first }}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="flex-1">[m
[32m+[m[32m                                <h3 class="font-semibold text-gray-900">{{ r.user.get_full_name }}</h3>[m
[32m+[m[32m                                <div class="flex items-center gap-4 text-sm text-gray-600 mt-1">[m
[32m+[m[32m                                    <span>{{ r.get_leave_type_display }}</span>[m
[32m+[m[32m                                    <span class="text-gray-400">•</span>[m
[32m+[m[32m                                    <span>{{ r.start_date|date:"j F Y" }} → {{ r.end_date|date:"j F Y" }}</span>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="flex items-center gap-2 px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm font-medium">[m
[32m+[m[32m                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                                    <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                                Отклонено[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                {% endfor %}[m
[32m+[m[32m            </div>[m
[32m+[m[32m        {% else %}[m
[32m+[m[32m            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 text-center">[m
[32m+[m[32m                <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">[m
[32m+[m[32m                    <svg class="w-8 h-8 text-gray-400" fill="currentColor" viewBox="0 0 20 20">[m
[32m+[m[32m                        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>[m
[32m+[m[32m                    </svg>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <p class="text-gray-500">Нет отклонённых заявок</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        {% endif %}[m
[32m+[m[32m    </div>[m
 </div>[m
 {% endblock %}[m
[32m+[m
[32m+[m[32m{% block extra_head %}[m
[32m+[m[32m    {% load static %}[m
[32m+[m[32m    <link rel="stylesheet" href="{% static 'css/approve_request.css' %}">[m
[32m+[m[32m    <style>[m
[32m+[m[32m        /* Дополнительные стили для улучшения визуального эффекта */[m
[32m+[m[32m        .container {[m
[32m+[m[32m            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);[m
[32m+[m[32m            min-height: 100vh;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .shadow-sm {[m
[32m+[m[32m            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .shadow-lg {[m
[32m+[m[32m            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .shadow-xl {[m
[32m+[m[32m            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .hover\:shadow-md:hover {[m
[32m+[m[32m            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);[m
[32m+[m[32m        }[m
[32m+[m[32m    </style>[m
[32m+[m[32m{% endblock %}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/templates/attendance.html b/tabelTrack/app/templates/attendance.html[m
[1mindex 0b2c79a..652f4e2 100644[m
[1m--- a/tabelTrack/app/templates/attendance.html[m
[1m+++ b/tabelTrack/app/templates/attendance.html[m
[36m@@ -3,67 +3,235 @@[m
 {% block title %}Мой табель{% endblock %}[m
 [m
 {% block content %}[m
[31m-<div class="max-w-6xl mx-auto p-6">[m
[31m-  <div class="flex justify-between items-center mb-4">[m
[31m-    <h2 class="text-2xl font-bold">📅 Табель учёта рабочего времени</h2>[m
[32m+[m[32m<div class="max-w-7xl mx-auto p-6">[m
[32m+[m[32m  <!-- Заголовок и фильтры -->[m
[32m+[m[32m  <div class="flex flex-col lg:flex-row justify-between items-start lg:items-center mb-8 gap-4">[m
[32m+[m[32m    <div>[m
[32m+[m[32m      <h1 class="text-3xl font-bold text-gray-900 mb-2">📅 Табель учёта рабочего времени</h1>[m
[32m+[m[32m      <p class="text-gray-600">Отслеживайте рабочее время и планируйте отпуска</p>[m
[32m+[m[32m    </div>[m
 [m
     <!-- Фильтр -->[m
[31m-    <form method="get" class="flex space-x-2">[m
[31m-      <select name="month" class="border rounded px-2 py-1 text-sm">[m
[31m-        {% for m in 1|to_range:12 %}[m
[31m-          <option value="{{ m }}" {% if m == today.month %}selected{% endif %}>{{ m }}</option>[m
[31m-        {% endfor %}[m
[31m-      </select>[m
[31m-      <select name="year" class="border rounded px-2 py-1 text-sm">[m
[31m-        {% for y in year_range %}[m
[31m-          <option value="{{ y }}" {% if y == today.year %}selected{% endif %}>{{ y }}</option>[m
[31m-        {% endfor %}[m
[31m-      </select>[m
[31m-      <button class="bg-indigo-600 text-white px-3 py-1 rounded text-sm hover:bg-indigo-700">[m
[32m+[m[32m    <form method="get" class="flex items-center space-x-3 bg-white rounded-xl shadow-sm p-4 border">[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <label class="text-sm font-medium text-gray-700">Месяц:</label>[m
[32m+[m[32m        <select name="month" class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-red-500 focus:border-red-500">[m
[32m+[m[32m          {% for m in 1|to_range:12 %}[m
[32m+[m[32m            <option value="{{ m }}" {% if m == today.month %}selected{% endif %}>[m
[32m+[m[32m              {% if m == 1 %}Январь{% elif m == 2 %}Февраль{% elif m == 3 %}Март{% elif m == 4 %}Апрель{% elif m == 5 %}Май{% elif m == 6 %}Июнь{% elif m == 7 %}Июль{% elif m == 8 %}Август{% elif m == 9 %}Сентябрь{% elif m == 10 %}Октябрь{% elif m == 11 %}Ноябрь{% elif m == 12 %}Декабрь{% endif %}[m
[32m+[m[32m            </option>[m
[32m+[m[32m          {% endfor %}[m
[32m+[m[32m        </select>[m
[32m+[m[32m      </div>[m
[32m+[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <label class="text-sm font-medium text-gray-700">Год:</label>[m
[32m+[m[32m        <select name="year" class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-red-500 focus:border-red-500">[m
[32m+[m[32m          {% for y in year_range %}[m
[32m+[m[32m            <option value="{{ y }}" {% if y == today.year %}selected{% endif %}>{{ y }}</option>[m
[32m+[m[32m          {% endfor %}[m
[32m+[m[32m        </select>[m
[32m+[m[32m      </div>[m
[32m+[m
[32m+[m[32m      <button class="bg-red-600 text-white px-6 py-2 rounded-lg text-sm font-medium hover:bg-red-700 transition-colors shadow-sm">[m
         Показать[m
       </button>[m
     </form>[m
   </div>[m
 [m
[32m+[m[32m  <!-- Статистические карточки -->[m
[32m+[m[32m  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">[m
[32m+[m[32m    <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">[m
[32m+[m[32m      <div class="flex items-center justify-between">[m
[32m+[m[32m        <div>[m
[32m+[m[32m          <p class="text-sm font-medium text-gray-600 mb-1">Отработано дней</p>[m
[32m+[m[32m          <p class="text-2xl font-bold text-gray-900">22</p>[m
[32m+[m[32m          <p class="text-xs text-gray-500">из 23 дней в месяце</p>[m
[32m+[m[32m        </div>[m
[32m+[m[32m        <div class="w-12 h-12 bg-red-50 rounded-lg flex items-center justify-center">[m
[32m+[m[32m          <div class="w-6 h-6 bg-red-500 rounded-full"></div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m      </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">[m
[32m+[m[32m      <div class="flex items-center justify-between">[m
[32m+[m[32m        <div>[m
[32m+[m[32m          <p class="text-sm font-medium text-gray-600 mb-1">Рабочих часов</p>[m
[32m+[m[32m          <p class="text-2xl font-bold text-gray-900">176</p>[m
[32m+[m[32m          <p class="text-xs text-gray-500">из 184 часов</p>[m
[32m+[m[32m        </div>[m
[32m+[m[32m        <div class="w-12 h-12 bg-blue-50 rounded-lg flex items-center justify-center">[m
[32m+[m[32m          <svg class="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>[m
[32m+[m[32m          </svg>[m
[32m+[m[32m        </div>[m
[32m+[m[32m      </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">[m
[32m+[m[32m      <div class="flex items-center justify-between">[m
[32m+[m[32m        <div>[m
[32m+[m[32m          <p class="text-sm font-medium text-gray-600 mb-1">Отпускные дни</p>[m
[32m+[m[32m          <p class="text-2xl font-bold text-gray-900">12</p>[m
[32m+[m[32m          <p class="text-xs text-gray-500">дней осталось</p>[m
[32m+[m[32m        </div>[m
[32m+[m[32m        <div class="w-12 h-12 bg-green-50 rounded-lg flex items-center justify-center">[m
[32m+[m[32m          <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064"/>[m
[32m+[m[32m          </svg>[m
[32m+[m[32m        </div>[m
[32m+[m[32m      </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">[m
[32m+[m[32m      <div class="flex items-center justify-between">[m
[32m+[m[32m        <div>[m
[32m+[m[32m          <p class="text-sm font-medium text-gray-600 mb-1">Активные заявки</p>[m
[32m+[m[32m          <p class="text-2xl font-bold text-gray-900">3</p>[m
[32m+[m[32m          <p class="text-xs text-gray-500">в обработке</p>[m
[32m+[m[32m        </div>[m
[32m+[m[32m        <div class="w-12 h-12 bg-orange-50 rounded-lg flex items-center justify-center">[m
[32m+[m[32m          <svg class="w-6 h-6 text-orange-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"/>[m
[32m+[m[32m          </svg>[m
[32m+[m[32m        </div>[m
[32m+[m[32m      </div>[m
[32m+[m[32m    </div>[m
[32m+[m[32m  </div>[m
[32m+[m
   <!-- Легенда -->[m
[31m-  <div class="flex flex-wrap gap-4 mb-4 text-sm text-gray-600">[m
[31m-    <div class="flex items-center"><div class="w-4 h-4 bg-green-300 rounded mr-1"></div>Работа</div>[m
[31m-    <div class="flex items-center"><div class="w-4 h-4 bg-blue-300 rounded mr-1"></div>Отпуск</div>[m
[31m-    <div class="flex items-center"><div class="w-4 h-4 bg-yellow-300 rounded mr-1"></div>Больничный</div>[m
[31m-    <div class="flex items-center"><div class="w-4 h-4 bg-red-300 rounded mr-1"></div>Неявка</div>[m
[31m-    <div class="flex items-center"><div class="w-4 h-4 bg-orange-300 rounded mr-1"></div>Выходной</div>[m
[31m-    <div class="flex items-center"><div class="w-4 h-4 bg-gray-400 rounded mr-1"></div>Праздник 🎉</div>[m
[32m+[m[32m  <div class="bg-white rounded-xl shadow-sm p-6 mb-8 border border-gray-100">[m
[32m+[m[32m    <h3 class="text-lg font-semibold text-gray-900 mb-4">Обозначения</h3>[m
[32m+[m[32m    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <div class="w-4 h-4 bg-green-500 rounded-full shadow-sm"></div>[m
[32m+[m[32m        <span class="text-sm text-gray-700 font-medium">Работа</span>[m
[32m+[m[32m      </div>[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <div class="w-4 h-4 bg-blue-500 rounded-full shadow-sm"></div>[m
[32m+[m[32m        <span class="text-sm text-gray-700 font-medium">Отпуск</span>[m
[32m+[m[32m      </div>[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <div class="w-4 h-4 bg-yellow-500 rounded-full shadow-sm"></div>[m
[32m+[m[32m        <span class="text-sm text-gray-700 font-medium">Больничный</span>[m
[32m+[m[32m      </div>[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <div class="w-4 h-4 bg-red-500 rounded-full shadow-sm"></div>[m
[32m+[m[32m        <span class="text-sm text-gray-700 font-medium">Неявка</span>[m
[32m+[m[32m      </div>[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <div class="w-4 h-4 bg-orange-500 rounded-full shadow-sm"></div>[m
[32m+[m[32m        <span class="text-sm text-gray-700 font-medium">Выходной</span>[m
[32m+[m[32m      </div>[m
[32m+[m[32m      <div class="flex items-center space-x-2">[m
[32m+[m[32m        <div class="w-4 h-4 bg-gray-500 rounded-full shadow-sm"></div>[m
[32m+[m[32m        <span class="text-sm text-gray-700 font-medium">Праздник 🎉</span>[m
[32m+[m[32m      </div>[m
[32m+[m[32m    </div>[m
   </div>[m
 [m
[31m-  <!-- Сетка -->[m
[31m-  <div class="grid grid-cols-7 gap-2 text-center text-sm font-medium">[m
[31m-    {% for d in weekdays %}[m
[31m-      <div class="py-2 text-gray-500">{{ d }}</div>[m
[31m-    {% endfor %}[m
[31m-[m
[31m-    {% for day in calendar %}[m
[31m-    {% if day.date %}[m
[31m-      <div class="rounded-lg p-2 h-24 flex flex-col justify-between relative shadow-sm transition hover:scale-[1.02][m
[31m-        {% if day.status == 'work' %}bg-green-200[m
[31m-        {% elif day.status == 'vacation' %}bg-blue-200[m
[31m-        {% elif day.status == 'sick' %}bg-yellow-200[m
[31m-        {% elif day.status == 'absent' %}bg-red-200[m
[31m-        {% elif day.status == 'weekend' %}bg-orange-200[m
[31m-        {% elif day.status == 'holiday' %}bg-gray-300[m
[31m-        {% else %}bg-gray-100{% endif %}">[m
[31m-        [m
[31m-        <div class="text-sm font-semibold">{{ day.date.day }}</div>[m
[31m-        <div class="text-xs text-gray-700 leading-tight">{{ day.status_label }}</div>[m
[31m-        <div class="text-[10px] text-gray-600">Норма: {{ day.hours_planned }} ч</div>[m
[31m-  [m
[31m-        {% if day.date == today %}[m
[31m-          <span class="absolute top-1 right-1 bg-white border text-xs rounded px-1 font-semibold text-indigo-500">Сегодня</span>[m
[32m+[m[32m  <!-- Календарь -->[m
[32m+[m[32m  <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">[m
[32m+[m[32m    <div class="p-6">[m
[32m+[m[32m      <div class="grid grid-cols-7 gap-2 mb-4">[m
[32m+[m[32m        {% for d in weekdays %}[m
[32m+[m[32m          <div class="text-center py-3 text-sm font-semibold text-gray-900 bg-gray-50 rounded-lg">{{ d }}</div>[m
[32m+[m[32m        {% endfor %}[m
[32m+[m[32m      </div>[m
[32m+[m
[32m+[m[32m      <div class="grid grid-cols-7 gap-2">[m
[32m+[m[32m        {% for day in calendar %}[m
[32m+[m[32m        {% if day.date %}[m
[32m+[m[32m          <div class="relative group">[m
[32m+[m[32m            <div class="rounded-xl p-4 h-28 flex flex-col justify-between transition-all duration-200 hover:scale-105 hover:shadow-md cursor-pointer[m
[32m+[m[32m              {% if day.status == 'work' %}bg-green-50 border-2 border-green-200 hover:border-green-300[m
[32m+[m[32m              {% elif day.status == 'vacation' %}bg-blue-50 border-2 border-blue-200 hover:border-blue-300[m
[32m+[m[32m              {% elif day.status == 'sick' %}bg-yellow-50 border-2 border-yellow-200 hover:border-yellow-300[m
[32m+[m[32m              {% elif day.status == 'absent' %}bg-red-50 border-2 border-red-200 hover:border-red-300[m
[32m+[m[32m              {% elif day.status == 'weekend' %}bg-orange-50 border-2 border-orange-200 hover:border-orange-300[m
[32m+[m[32m              {% elif day.status == 'holiday' %}bg-gray-100 border-2 border-gray-300 hover:border-gray-400[m
[32m+[m[32m              {% else %}bg-gray-50 border-2 border-gray-200 hover:border-gray-300{% endif %}">[m
[32m+[m
[32m+[m[32m              <div class="flex justify-between items-start">[m
[32m+[m[32m                <span class="text-lg font-bold text-gray-900">{{ day.date.day }}</span>[m
[32m+[m[32m                {% if day.status == 'work' %}[m
[32m+[m[32m                  <div class="w-2 h-2 bg-green-500 rounded-full"></div>[m
[32m+[m[32m                {% elif day.status == 'vacation' %}[m
[32m+[m[32m                  <div class="w-2 h-2 bg-blue-500 rounded-full"></div>[m
[32m+[m[32m                {% elif day.status == 'sick' %}[m
[32m+[m[32m                  <div class="w-2 h-2 bg-yellow-500 rounded-full"></div>[m
[32m+[m[32m                {% elif day.status == 'absent' %}[m
[32m+[m[32m                  <div class="w-2 h-2 bg-red-500 rounded-full"></div>[m
[32m+[m[32m                {% elif day.status == 'weekend' %}[m
[32m+[m[32m                  <div class="w-2 h-2 bg-orange-500 rounded-full"></div>[m
[32m+[m[32m                {% elif day.status == 'holiday' %}[m
[32m+[m[32m                  <div class="w-2 h-2 bg-gray-500 rounded-full"></div>[m
[32m+[m[32m                {% endif %}[m
[32m+[m[32m              </div>[m
[32m+[m
[32m+[m[32m              <div class="space-y-1">[m
[32m+[m[32m                <div class="text-xs font-medium[m
[32m+[m[32m                  {% if day.status == 'work' %}text-green-700[m
[32m+[m[32m                  {% elif day.status == 'vacation' %}text-blue-700[m
[32m+[m[32m                  {% elif day.status == 'sick' %}text-yellow-700[m
[32m+[m[32m                  {% elif day.status == 'absent' %}text-red-700[m
[32m+[m[32m                  {% elif day.status == 'weekend' %}text-orange-700[m
[32m+[m[32m                  {% elif day.status == 'holiday' %}text-gray-700[m
[32m+[m[32m                  {% else %}text-gray-600{% endif %}">[m
[32m+[m[32m                  {{ day.status_label }}[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="text-xs text-gray-500 font-medium">{{ day.hours_planned }} ч</div>[m
[32m+[m[32m              </div>[m
[32m+[m
[32m+[m[32m              {% if day.date == today %}[m
[32m+[m[32m                <div class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-6 h-6 flex items-center justify-center font-bold shadow-lg">[m
[32m+[m[32m                  •[m
[32m+[m[32m                </div>[m
[32m+[m[32m              {% endif %}[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Tooltip при наведении -->[m
[32m+[m[32m            <div class="invisible group-hover:visible absolute top-full left-1/2 transform -translate-x-1/2 mt-2 px-3 py-2 bg-gray-900 text-white text-xs rounded-lg shadow-lg z-10 whitespace-nowrap">[m
[32m+[m[32m              {{ day.date.day }} - {{ day.status_label }} ({{ day.hours_planned }} ч)[m
[32m+[m[32m              <div class="absolute -top-1 left-1/2 transform -translate-x-1/2 w-2 h-2 bg-gray-900 rotate-45"></div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m          </div>[m
[32m+[m[32m        {% else %}[m
[32m+[m[32m          <div class="p-4 h-28"></div> <!-- Пустая ячейка -->[m
         {% endif %}[m
[32m+[m[32m        {% endfor %}[m
       </div>[m
[31m-    {% else %}[m
[31m-      <div class="p-2 h-24"></div> <!-- Пустая ячейка -->[m
[31m-    {% endif %}[m
[31m-  {% endfor %}  [m
[32m+[m[32m    </div>[m
[32m+[m[32m  </div>[m
[32m+[m
[32m+[m[32m  <!-- Быстрые действия -->[m
[32m+[m[32m  <div class="mt-8 flex flex-col sm:flex-row gap-4">[m
[32m+[m[32m    <button class="bg-red-600 text-white px-6 py-3 rounded-xl font-medium hover:bg-red-700 transition-colors shadow-sm flex items-center justify-center space-x-2">[m
[32m+[m[32m      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>[m
[32m+[m[32m      </svg>[m
[32m+[m[32m      <span>Подать заявку на отпуск</span>[m
[32m+[m[32m    </button>[m
[32m+[m
[32m+[m[32m    <button class="bg-white text-gray-700 px-6 py-3 rounded-xl font-medium hover:bg-gray-50 transition-colors shadow-sm border border-gray-200 flex items-center justify-center space-x-2">[m
[32m+[m[32m      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>[m
[32m+[m[32m      </svg>[m
[32m+[m[32m      <span>Экспорт табеля</span>[m
[32m+[m[32m    </button>[m
   </div>[m
 </div>[m
[31m-{% endblock %}[m
[32m+[m
[32m+[m[32m<style>[m
[32m+[m[32m/* Дополнительные стили для анимаций */[m
[32m+[m[32m@keyframes pulse-today {[m
[32m+[m[32m  0%, 100% { opacity: 1; }[m
[32m+[m[32m  50% { opacity: 0.7; }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32m.pulse-today {[m
[32m+[m[32m  animation: pulse-today 2s infinite;[m
[32m+[m[32m}[m
[32m+[m[32m</style>[m
[32m+[m[32m{% endblock %}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/templates/base.html b/tabelTrack/app/templates/base.html[m
[1mindex 13e4ff6..6611b70 100644[m
[1m--- a/tabelTrack/app/templates/base.html[m
[1m+++ b/tabelTrack/app/templates/base.html[m
[36m@@ -1,18 +1,191 @@[m
[31m-<!-- app/templates/base.html -->[m
 <!DOCTYPE html>[m
 <html lang="ru">[m
 <head>[m
[31m-  <meta charset="UTF-8">[m
[31m-  <title>{% block title %}TabelTrack{% endblock %}</title>[m
[31m-  <script src="https://cdn.tailwindcss.com"></script>[m
[32m+[m[32m    <meta charset="UTF-8">[m
[32m+[m[32m    <meta name="viewport" content="width=device-width, initial-scale=1.0">[m
[32m+[m[32m    <title>{% block title %}Ростелеком - HR Система{% endblock %}</title>[m
[32m+[m[32m    <script src="https://cdn.tailwindcss.com"></script>[m
[32m+[m[32m    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">[m
[32m+[m[32m    {% load static %}[m
[32m+[m[32m    <link rel="stylesheet" href="{% static 'css/base.css' %}">[m
[32m+[m[32m    <link rel="stylesheet" href="{% static 'css/dashboard.css' %}">[m
[32m+[m[32m    <link rel="stylesheet" href="{% static 'css/leave_request.css' %}">[m
 </head>[m
[31m-<body class="bg-gray-100 text-gray-900">[m
[31m-  <header class="bg-white shadow p-4 mb-6">[m
[31m-    <div class="max-w-7xl mx-auto text-xl font-semibold">TabelTrack</div>[m
[31m-  </header>[m
[31m-[m
[31m-  <main class="max-w-7xl mx-auto px-4">[m
[31m-    {% block content %}{% endblock %}[m
[31m-  </main>[m
[32m+[m[32m<body>[m
[32m+[m[32m    <!-- Mobile Overlay -->[m
[32m+[m[32m    <div class="mobile-overlay md:hidden" id="mobileOverlay"></div>[m
[32m+[m
[32m+[m[32m    <!-- Sidebar -->[m
[32m+[m[32m    <div class="sidebar fixed left-0 top-0 h-full w-64 z-50" id="sidebar">[m
[32m+[m[32m        <!-- Toggle Button -->[m
[32m+[m[32m        <div class="sidebar-toggle" id="sidebarToggle">[m
[32m+[m[32m            <i class="fas fa-chevron-left"></i>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        <!-- Logo Section -->[m
[32m+[m[32m        <div class="p-6 border-b border-gray-600 border-opacity-30">[m
[32m+[m[32m            <div class="flex items-center space-x-3">[m
[32m+[m[32m                <div class="rt-logo w-12 h-12 rounded-xl flex items-center justify-center shadow-lg">[m
[32m+[m[32m                    <i class="fas fa-network-wired text-xl"></i>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-text">[m
[32m+[m[32m                    <h3 class="text-white text-lg font-bold">Ростелеком</h3>[m
[32m+[m[32m                    <p class="text-slate-300 text-sm">HR Система</p>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        <!-- Navigation Menu -->[m
[32m+[m[32m        <nav class="p-4 flex-1 overflow-y-auto">[m
[32m+[m[32m            <!-- Main Menu -->[m
[32m+[m[32m            <div class="space-y-2">[m
[32m+[m[32m                <div class="sidebar-item active px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-home w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text font-medium">Главная</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-calendar-alt w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Мой табель</span>[m
[32m+[m[32m                    <span class="rt-badge sidebar-text ml-auto">2</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-clock w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Учёт времени</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-paper-plane w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Заявки</span>[m
[32m+[m[32m                    <span class="rt-badge sidebar-text ml-auto">3</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Reports Section -->[m
[32m+[m[32m            <div class="sidebar-section-title">Отчёты</div>[m
[32m+[m[32m            <div class="space-y-2">[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-chart-bar w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Статистика</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-file-export w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Экспорт данных</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-history w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">История</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Settings Section -->[m
[32m+[m[32m            <div class="sidebar-section-title">Настройки</div>[m
[32m+[m[32m            <div class="space-y-2">[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-user-cog w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Профиль</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-bell w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Уведомления</span>[m
[32m+[m[32m                    <span class="rt-badge sidebar-text ml-auto">5</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-cog w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Настройки</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Support Section -->[m
[32m+[m[32m            <div class="sidebar-section-title">Поддержка</div>[m
[32m+[m[32m            <div class="space-y-2">[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-question-circle w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Справка</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="sidebar-item px-4 py-3 cursor-pointer flex items-center space-x-3 rounded-lg">[m
[32m+[m[32m                    <i class="fas fa-headset w-5 text-center"></i>[m
[32m+[m[32m                    <span class="sidebar-text">Поддержка</span>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </nav>[m
[32m+[m
[32m+[m[32m        <!-- User Profile -->[m
[32m+[m[32m        <div class="p-4 border-t border-gray-600 border-opacity-30">[m
[32m+[m[32m            <div class="rt-card rounded-xl p-4">[m
[32m+[m[32m                <div class="flex items-center space-x-3">[m
[32m+[m[32m                    <div class="rt-logo w-10 h-10 rounded-lg flex items-center justify-center text-sm font-bold">[m
[32m+[m[32m                        АИ[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <div class="sidebar-text flex-1">[m
[32m+[m[32m                        <p class="font-semibold text-sm text-gray-900">Андрей Иванов</p>[m
[32m+[m[32m                        <p class="text-gray-500 text-xs">Сотрудник</p>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <!-- Mobile Menu Button -->[m
[32m+[m[32m    <button class="md:hidden fixed top-4 left-4 z-50 rt-button rounded-lg" id="mobileMenuBtn">[m
[32m+[m[32m        <i class="fas fa-bars"></i>[m
[32m+[m[32m    </button>[m
[32m+[m
[32m+[m[32m    <!-- Main Content -->[m
[32m+[m[32m    <div class="main-content ml-64 md:ml-64" id="mainContent">[m
[32m+[m[32m        {% block content %}{% endblock %}[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <!-- JavaScript -->[m
[32m+[m[32m    <script>[m
[32m+[m[32m        const sidebar = document.getElementById('sidebar');[m
[32m+[m[32m        const sidebarToggle = document.getElementById('sidebarToggle');[m
[32m+[m[32m        const mobileMenuBtn = document.getElementById('mobileMenuBtn');[m
[32m+[m[32m        const mobileOverlay = document.getElementById('mobileOverlay');[m
[32m+[m[32m        const mainContent = document.getElementById('mainContent');[m
[32m+[m
[32m+[m[32m        // Sidebar Toggle[m
[32m+[m[32m        sidebarToggle.addEventListener('click', () => {[m
[32m+[m[32m            sidebar.classList.toggle('sidebar-collapsed');[m
[32m+[m[32m            if (sidebar.classList.contains('sidebar-collapsed')) {[m
[32m+[m[32m                mainContent.classList.remove('ml-64');[m
[32m+[m[32m                mainContent.classList.add('ml-20');[m
[32m+[m[32m            } else {[m
[32m+[m[32m                mainContent.classList.remove('ml-20');[m
[32m+[m[32m                mainContent.classList.add('ml-64');[m
[32m+[m[32m            }[m
[32m+[m[32m        });[m
[32m+[m
[32m+[m[32m        // Mobile Menu Toggle[m
[32m+[m[32m        mobileMenuBtn.addEventListener('click', () => {[m
[32m+[m[32m            sidebar.classList.toggle('mobile-open');[m
[32m+[m[32m            mobileOverlay.classList.toggle('active');[m
[32m+[m[32m        });[m
[32m+[m
[32m+[m[32m        mobileOverlay.addEventListener('click', () => {[m
[32m+[m[32m            sidebar.classList.remove('mobile-open');[m
[32m+[m[32m            mobileOverlay.classList.remove('active');[m
[32m+[m[32m        });[m
[32m+[m
[32m+[m[32m        // Dynamic Date and Time[m
[32m+[m[32m        function updateDateTime() {[m
[32m+[m[32m            const now = new Date();[m
[32m+[m[32m            const options = {[m
[32m+[m[32m                day: 'numeric',[m
[32m+[m[32m                month: 'long',[m
[32m+[m[32m                year: 'numeric',[m
[32m+[m[32m                hour: '2-digit',[m
[32m+[m[32m                minute: '2-digit'[m
[32m+[m[32m            };[m
[32m+[m[32m            document.getElementById('current-datetime').innerHTML = `<i class="fas fa-clock"></i> ${now.toLocaleString('ru-RU', options)}`;[m
[32m+[m[32m        }[m
[32m+[m[32m        setInterval(updateDateTime, 1000);[m
[32m+[m[32m        updateDateTime();[m
[32m+[m
[32m+[m[32m        // Dynamic Greeting[m
[32m+[m[32m        const hours = new Date().getHours();[m
[32m+[m[32m        let greeting = 'Доброе утро';[m
[32m+[m[32m        if (hours >= 12 && hours < 17) greeting = 'Добрый день';[m
[32m+[m[32m        else if (hours >= 17 || hours < 5) greeting = 'Добрый вечер';[m
[32m+[m[32m        document.getElementById('greeting').textContent = greeting;[m
[32m+[m[32m    </script>[m
 </body>[m
[31m-</html>[m
[32m+[m[32m</html>[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/templates/dashboard.html b/tabelTrack/app/templates/dashboard.html[m
[1mdeleted file mode 100644[m
[1mindex 6446aec..0000000[m
[1m--- a/tabelTrack/app/templates/dashboard.html[m
[1m+++ /dev/null[m
[36m@@ -1,165 +0,0 @@[m
[31m-{% extends "base.html" %}[m
[31m-{% block title %}Дашборд{% endblock %}[m
[31m-[m
[31m-{% block content %}[m
[31m-<div class="max-w-7xl mx-auto p-6">[m
[31m-[m
[31m-  <!-- Верхняя панель -->[m
[31m-  <div class="flex items-center justify-between mb-8 bg-white shadow rounded-lg p-4">[m
[31m-    <div class="flex items-center">[m
[31m-      <img src="https://ui-avatars.com/api/?name={{ user.get_full_name }}" alt="avatar"[m
[31m-           class="w-14 h-14 rounded-full shadow mr-4">[m
[31m-      <div>[m
[31m-        <h1 class="text-xl font-bold text-gray-800">👋 Добро пожаловать, {{ user.get_full_name }}</h1>[m
[31m-        <p class="text-sm text-gray-500">Роль: {{ user.role|title }}</p>[m
[31m-      </div>[m
[31m-    </div>[m
[31m-    <form action="{% url 'logout' %}" method="post">[m
[31m-      {% csrf_token %}[m
[31m-      <button type="submit" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition">Выйти</button>[m
[31m-    </form>[m
[31m-  </div>[m
[31m-[m
[31m-  <!-- Совет дня -->[m
[31m-  <div class="bg-purple-100 p-4 rounded-lg shadow mb-8">[m
[31m-    <p class="font-semibold text-purple-800">💡 Совет дня:</p>[m
[31m-    <p class="text-sm text-purple-600">Не забудьте отметить явку и проверьте, не забыли ли подать заявку на отпуск.</p>[m
[31m-  </div>[m
[31m-[m
[31m-  {% if user.role == 'worker' %}[m
[31m-    <!-- Блок карточек -->[m
[31m-    <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">[m
[31m-      <div class="p-5 bg-green-100 rounded-xl shadow text-center">[m
[31m-        <p class="text-gray-600">✅ Отработано</p>[m
[31m-        <p class="text-3xl font-bold text-green-700">{{ worked_days }}</p>[m
[31m-      </div>[m
[31m-      <div class="p-5 bg-blue-100 rounded-xl shadow text-center">[m
[31m-        <p class="text-gray-600">🏖️ Отпуск</p>[m
[31m-        <p class="text-3xl font-bold text-blue-700">{{ vacation_days }}</p>[m
[31m-      </div>[m
[31m-      <div class="p-5 bg-yellow-100 rounded-xl shadow text-center">[m
[31m-        <p class="text-gray-600">🤒 Больничный</p>[m
[31m-        <p class="text-3xl font-bold text-yellow-700">{{ sick_days }}</p>[m
[31m-      </div>[m
[31m-      <div class="p-5 bg-red-100 rounded-xl shadow text-center">[m
[31m-        <p class="text-gray-600">⛔ Пропущено</p>[m
[31m-        <p class="text-3xl font-bold text-red-700">{{ absent_days }}</p>[m
[31m-      </div>[m
[31m-    </div>[m
[31m-[m
[31m-    <!-- Кнопки -->[m
[31m-    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">[m
[31m-      <a href="{% url 'attendance' %}" class="py-4 bg-indigo-500 hover:bg-indigo-600 text-white rounded-xl shadow text-center transition">[m
[31m-        📅 Мой табель[m
[31m-      </a>[m
[31m-      <a href="{% url 'leave_request' %}" class="py-4 bg-teal-500 hover:bg-teal-600 text-white rounded-xl shadow text-center transition">[m
[31m-        📝 Подать заявку[m
[31m-      </a>[m
[31m-    </div>[m
[31m-[m
[31m-    <!-- Последние заявки -->[m
[31m-    <div class="bg-white shadow rounded-lg p-4">[m
[31m-      <h2 class="font-bold text-lg text-gray-700 mb-4">🗂️ Последние заявки</h2>[m
[31m-      <ul class="divide-y">[m
[31m-        {% for req in my_requests %}[m
[31m-          <li class="py-3 flex justify-between items-center">[m
[31m-            <span class="text-gray-700">{{ req.get_leave_type_display }}: {{ req.start_date }} – {{ req.end_date }}</span>[m
[31m-            <span class="text-sm px-2 py-1 rounded font-medium[m
[31m-              {% if req.status == 'approved' %}bg-green-100 text-green-700[m
[31m-              {% elif req.status == 'rejected' %}bg-red-100 text-red-700[m
[31m-              {% else %}bg-yellow-100 text-yellow-700{% endif %}">[m
[31m-              {% if req.status == 'approved' %}✅ Одобрено{% elif req.status == 'rejected' %}❌ Отклонено{% else %}⏳ В ожидании{% endif %}[m
[31m-            </span>[m
[31m-          </li>[m
[31m-        {% empty %}[m
[31m-          <li class="text-gray-500">Нет заявок.</li>[m
[31m-        {% endfor %}[m
[31m-      </ul>[m
[31m-    </div>[m
[31m-  {% elif user.role == 'editor' %}[m
[31m-    <!-- Editor блок -->[m
[31m-    <div class="mb-8 bg-yellow-100 p-4 rounded-xl shadow">[m
[31m-      <h2 class="text-lg font-semibold text-yellow-700 mb-2">🛠️ Задача редактора</h2>[m
[31m-      <p class="text-gray-700">Проверьте табели сотрудников за текущий период и при необходимости внесите корректировки.</p>[m
[31m-    </div>[m
[31m-    <a href="{% url 'edit_attendance' %}" class="py-4 bg-yellow-500 hover:bg-yellow-600 text-white rounded-xl shadow text-center transition block">[m
[31m-      🛠 Редактировать табель сотрудников[m
[31m-    </a>[m
[31m-  {% elif user.role == 'approver' %}[m
[31m-    <!-- Approver: Блок статистики -->[m
[31m-    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">[m
[31m-      <div class="bg-green-100 rounded-lg shadow p-4">[m
[31m-        <h2 class="text-sm text-green-700">✅ Сегодня на работе</h2>[m
[31m-        <p class="text-3xl font-bold text-green-800">{{ stats.today_present }}/{{ stats.total_employees }}</p>[m
[31m-      </div>[m
[31m-      <div class="bg-yellow-100 rounded-lg shadow p-4">[m
[31m-        <h2 class="text-sm text-yellow-700">🤒 На больничном</h2>[m
[31m-        <p class="text-3xl font-bold text-yellow-800">{{ stats.today_sick }}</p>[m
[31m-      </div>[m
[31m-      <div class="bg-blue-100 rounded-lg shadow p-4">[m
[31m-        <h2 class="text-sm text-blue-700">🏖️ В отпуске</h2>[m
[31m-        <p class="text-3xl font-bold text-blue-800">{{ stats.today_vacation }}</p>[m
[31m-      </div>[m
[31m-    </div>[m
[31m-[m
[31m-    <!-- График -->[m
[31m-    <div class="mb-6 bg-white rounded-lg shadow p-4">[m
[31m-      <h2 class="text-lg font-semibold text-gray-800 mb-4">📈 Отчётность по явке за месяц</h2>[m
[31m-      <canvas id="attendanceChart" height="100"></canvas>[m
[31m-    </div>[m
[31m-[m
[31m-    <!-- Последние заявки сотрудников -->[m
[31m-    <div class="bg-white shadow rounded-lg p-4 mb-6">[m
[31m-      <div class="flex justify-between items-center mb-4">[m
[31m-        <h2 class="font-bold text-lg text-gray-700">📋 Последние заявки сотрудников</h2>[m
[31m-        <a href="{% url 'approve_requests' %}" class="text-sm text-indigo-600 hover:underline">Смотреть все →</a>[m
[31m-      </div>[m
[31m-      <ul class="divide-y">[m
[31m-        {% for req in team_requests %}[m
[31m-          <li class="py-2 flex justify-between items-center">[m
[31m-            <div>[m
[31m-              <p class="font-medium text-gray-700">{{ req.user.get_full_name }}</p>[m
[31m-              <p class="text-sm text-gray-500">{{ req.get_leave_type_display }}: {{ req.start_date }} – {{ req.end_date }}</p>[m
[31m-            </div>[m
[31m-            <span class="text-sm px-2 py-1 rounded font-medium[m
[31m-              {% if req.status == 'approved' %}bg-green-100 text-green-700[m
[31m-              {% elif req.status == 'rejected' %}bg-red-100 text-red-700[m
[31m-              {% else %}bg-yellow-100 text-yellow-700{% endif %}">[m
[31m-              {% if req.status == 'approved' %}✅ Одобрено{% elif req.status == 'rejected' %}❌ Отклонено{% else %}⏳ В ожидании{% endif %}[m
[31m-            </span>[m
[31m-          </li>[m
[31m-        {% empty %}[m
[31m-          <li class="text-gray-500">Нет заявок от сотрудников.</li>[m
[31m-        {% endfor %}[m
[31m-      </ul>[m
[31m-    </div>[m
[31m-[m
[31m-    <!-- Команда -->[m
[31m-    <div class="bg-white shadow rounded-lg p-4">[m
[31m-      <h2 class="font-bold text-lg text-gray-700 mb-4">👥 Команда</h2>[m
[31m-      <table class="min-w-full divide-y">[m
[31m-        <thead class="bg-gray-100">[m
[31m-          <tr>[m
[31m-            <th class="px-4 py-2 text-sm text-gray-600">ФИО</th>[m
[31m-            <th class="px-4 py-2 text-sm text-gray-600">Должность</th>[m
[31m-            <th class="px-4 py-2 text-sm text-gray-600">Отработано</th>[m
[31m-            <th class="px-4 py-2 text-sm text-gray-600">Больничный</th>[m
[31m-            <th class="px-4 py-2 text-sm text-gray-600">Отпуск</th>[m
[31m-          </tr>[m
[31m-        </thead>[m
[31m-        <tbody>[m
[31m-          {% for member in team_members %}[m
[31m-            <tr class="hover:bg-gray-50">[m
[31m-              <td class="px-4 py-2">{{ member.get_full_name }}</td>[m
[31m-              <td class="px-4 py-2">{{ member.position }}</td>[m
[31m-              <td class="px-4 py-2">{{ member.worked_days }}</td>[m
[31m-              <td class="px-4 py-2">{{ member.sick_days }}</td>[m
[31m-              <td class="px-4 py-2">{{ member.vacation_days }}</td>[m
[31m-            </tr>[m
[31m-          {% endfor %}[m
[31m-        </tbody>[m
[31m-      </table>[m
[31m-    </div>[m
[31m-  {% endif %}[m
[31m-</div>[m
[31m-{% endblock %}[m
[1mdiff --git a/tabelTrack/app/templates/dashboard_approver.html b/tabelTrack/app/templates/dashboard_approver.html[m
[1mnew file mode 100644[m
[1mindex 0000000..b3f8bd6[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/templates/dashboard_approver.html[m
[36m@@ -0,0 +1,122 @@[m
[32m+[m[32m{% extends 'base.html' %}[m
[32m+[m
[32m+[m[32m{% block content %}[m
[32m+[m[32m<div class="container mx-auto px-6 py-6 max-w-7xl">[m
[32m+[m[32m    <div class="rt-header">[m
[32m+[m[32m        <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">[m
[32m+[m[32m            <div class="flex items-center space-x-4">[m
[32m+[m[32m                <div class="rt-logo w-16 h-16 rounded-xl flex items-center justify-center text-2xl shadow-lg">[m
[32m+[m[32m                    <i class="fas fa-user-tie"></i>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div>[m
[32m+[m[32m                    <h1 class="text-3xl font-bold text-gray-900 mb-2">[m
[32m+[m[32m                        <span id="greeting">[m
[32m+[m[32m                            {% now "H" as current_hour %}[m
[32m+[m[32m                            {% if current_hour|add:"0" < 12 %}Доброе утро[m
[32m+[m[32m                            {% elif current_hour|add:"0" < 18 %}Добрый день[m
[32m+[m[32m                            {% else %}Добрый вечер{% endif %}[m
[32m+[m[32m                        </span>, {{ user.get_full_name }}![m
[32m+[m[32m                    </h1>[m
[32m+[m[32m                    <div class="flex items-center space-x-6 text-sm text-gray-600">[m
[32m+[m[32m                        <div class="flex items-center space-x-2">[m
[32m+[m[32m                            <span class="status-indicator"></span>[m
[32m+[m[32m                            <span class="font-medium">Онлайн</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div id="current-datetime" class="flex items-center space-x-1">[m
[32m+[m[32m                            <i class="fas fa-clock"></i>[m
[32m+[m[32m                            <span>{% now "d.m.Y H:i" %}</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <button class="rt-button-outline">[m
[32m+[m[32m                <i class="fas fa-sign-out-alt mr-2"></i>Выйти[m
[32m+[m[32m            </button>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="notification-card rounded-xl p-6 mb-8">[m
[32m+[m[32m        <div class="flex items-center space-x-4">[m
[32m+[m[32m            <div class="rt-secondary w-12 h-12 rounded-xl flex items-center justify-center shadow-lg">[m
[32m+[m[32m                <i class="fas fa-info-circle text-xl"></i>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div>[m
[32m+[m[32m                <h3 class="font-semibold text-blue-900 mb-2">Уведомление</h3>[m
[32m+[m[32m                <p class="text-blue-800 text-sm">У вас {{ all_requests|length }} заявок на рассмотрении.</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <h3 class="rt-section-title"><i class="fas fa-users"></i>Статистика команды</h3>[m
[32m+[m[32m        <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon"><i class="fas fa-check-circle"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">На работе</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ stats.today_present }}</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon blue"><i class="fas fa-umbrella-beach"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">В отпуске</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ stats.today_vacation }}</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon green"><i class="fas fa-home"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">На больничном</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ stats.today_sick }}</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon yellow"><i class="fas fa-users"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">Всего сотрудников</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ stats.total_employees }}</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <h3 class="rt-section-title"><i class="fas fa-paper-plane"></i>Заявки на согласование</h3>[m
[32m+[m[32m        <div class="space-y-4">[m
[32m+[m[32m            {% for request in all_requests %}[m
[32m+[m[32m                {% if request.status == 'pending' %}[m
[32m+[m[32m                    <div class="rt-request-card {{ request.status }}">[m
[32m+[m[32m                        <div class="flex items-center justify-between">[m
[32m+[m[32m                            <div class="flex items-center space-x-4">[m
[32m+[m[32m                                <div class="rt-stat-icon {{ request.status }}">[m
[32m+[m[32m                                    {% if request.leave_type == 'vacation' %}<i class="fas fa-umbrella-beach"></i>[m
[32m+[m[32m                                    {% elif request.leave_type == 'sick' %}<i class="fas fa-home"></i>[m
[32m+[m[32m                                    {% else %}<i class="fas fa-suitcase"></i>{% endif %}[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                                <div>[m
[32m+[m[32m                                    <p class="font-semibold text-gray-900">{{ request.user.get_full_name }}</p>[m
[32m+[m[32m                                    <p class="text-gray-500 text-sm">{{ request.start_date|date:"d.m.Y" }} - {{ request.end_date|date:"d.m.Y" }}</p>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <a href="{% url 'approve_requests' %}" class="text-yellow-600 text-sm font-medium bg-yellow-100 px-3 py-1 rounded-full">Рассмотреть</a>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                {% endif %}[m
[32m+[m[32m            {% empty %}[m
[32m+[m[32m                <p class="text-gray-500">Нет заявок на рассмотрении.</p>[m
[32m+[m[32m            {% endfor %}[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <h3 class="rt-section-title"><i class="fas fa-user"></i>Мои данные</h3>[m
[32m+[m[32m        <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon"><i class="fas fa-check-circle"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">Отработано дней</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ worked_days }}</p>[m
[32m+[m[32m                <div class="rt-progress mt-3"><div class="rt-progress-bar" style="width: {{ progress_percentage }}%"></div></div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon green"><i class="fas fa-umbrella-beach"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">Отпускные дни</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ available_days }}</p>[m
[32m+[m[32m                <div class="rt-progress mt-3"><div class="rt-progress-bar" style="width: {{ vacation_progress }}%"></div></div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m[32m</div>[m
[32m+[m[32m{% endblock %}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/templates/dashboard_editor.html b/tabelTrack/app/templates/dashboard_editor.html[m
[1mnew file mode 100644[m
[1mindex 0000000..c4b9eb5[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/templates/dashboard_editor.html[m
[36m@@ -0,0 +1,73 @@[m
[32m+[m[32m{% extends 'base.html' %}[m
[32m+[m
[32m+[m[32m{% block content %}[m
[32m+[m[32m<div class="container mx-auto px-6 py-6 max-w-7xl">[m
[32m+[m[32m    <div class="rt-header">[m
[32m+[m[32m        <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">[m
[32m+[m[32m            <div class="flex items-center space-x-4">[m
[32m+[m[32m                <div class="rt-logo w-16 h-16 rounded-xl flex items-center justify-center text-2xl shadow-lg">[m
[32m+[m[32m                    <i class="fas fa-user-tie"></i>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div>[m
[32m+[m[32m                    <h1 class="text-3xl font-bold text-gray-900 mb-2">[m
[32m+[m[32m                        <span id="greeting">[m
[32m+[m[32m                            {% now "H" as current_hour %}[m
[32m+[m[32m                            {% if current_hour|add:"0" < 12 %}Доброе утро[m
[32m+[m[32m                            {% elif current_hour|add:"0" < 18 %}Добрый день[m
[32m+[m[32m                            {% else %}Добрый вечер{% endif %}[m
[32m+[m[32m                        </span>, {{ user.get_full_name }}![m
[32m+[m[32m                    </h1>[m
[32m+[m[32m                    <div class="flex items-center space-x-6 text-sm text-gray-600">[m
[32m+[m[32m                        <div class="flex items-center space-x-2">[m
[32m+[m[32m                            <span class="status-indicator"></span>[m
[32m+[m[32m                            <span class="font-medium">Онлайн</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div id="current-datetime" class="flex items-center space-x-1">[m
[32m+[m[32m                            <i class="fas fa-clock"></i>[m
[32m+[m[32m                            <span>{% now "d.m.Y H:i" %}</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <button class="rt-button-outline">[m
[32m+[m[32m                <i class="fas fa-sign-out-alt mr-2"></i>Выйти[m
[32m+[m[32m            </button>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="notification-card rounded-xl p-6 mb-8">[m
[32m+[m[32m        <div class="flex items-center space-x-4">[m
[32m+[m[32m            <div class="rt-secondary w-12 h-12 rounded-xl flex items-center justify-center shadow-lg">[m
[32m+[m[32m                <i class="fas fa-info-circle text-xl"></i>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div>[m
[32m+[m[32m                <h3 class="font-semibold text-blue-900 mb-2">Уведомление</h3>[m
[32m+[m[32m                <p class="text-blue-800 text-sm">Проверьте и обновите табель сотрудников.</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <a href="{% url 'edit_attendance' %}" class="rt-quick-action mb-8 block">[m
[32m+[m[32m        <i class="fas fa-edit text-3xl"></i>[m
[32m+[m[32m        <p class="font-semibold text-gray-900">Редактировать табель</p>[m
[32m+[m[32m    </a>[m
[32m+[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <h3 class="rt-section-title"><i class="fas fa-user"></i>Мои данные</h3>[m
[32m+[m[32m        <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon"><i class="fas fa-check-circle"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">Отработано дней</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ worked_days }}</p>[m
[32m+[m[32m                <div class="rt-progress mt-3"><div class="rt-progress-bar" style="width: {{ progress_percentage }}%"></div></div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div class="rt-stat-card">[m
[32m+[m[32m                <div class="rt-stat-icon green"><i class="fas fa-umbrella-beach"></i></div>[m
[32m+[m[32m                <p class="text-gray-600 text-sm mb-2 font-medium">Отпускные дни</p>[m
[32m+[m[32m                <p class="text-3xl font-bold text-gray-900 mb-2">{{ available_days }}</p>[m
[32m+[m[32m                <div class="rt-progress mt-3"><div class="rt-progress-bar" style="width: {{ vacation_progress }}%"></div></div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m[32m</div>[m
[32m+[m[32m{% endblock %}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/utils/__init__.py b/tabelTrack/app/templates/dashboard_user.html[m
[1msimilarity index 100%[m
[1mrename from tabelTrack/utils/__init__.py[m
[1mrename to tabelTrack/app/templates/dashboard_user.html[m
[1mdiff --git a/tabelTrack/app/templates/dashboard_worker.html b/tabelTrack/app/templates/dashboard_worker.html[m
[1mnew file mode 100644[m
[1mindex 0000000..fb57795[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/templates/dashboard_worker.html[m
[36m@@ -0,0 +1,116 @@[m
[32m+[m[32m{% extends 'base.html' %}[m
[32m+[m
[32m+[m[32m{% block content %}[m
[32m+[m[32m<div class="container mx-auto px-6 py-6 max-w-7xl">[m
[32m+[m[32m    <div class="rt-header">[m
[32m+[m[32m        <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">[m
[32m+[m[32m            <div class="flex items-center space-x-4">[m
[32m+[m[32m                <div class="rt-logo w-16 h-16 rounded-xl flex items-center justify-center text-2xl shadow-lg">[m
[32m+[m[32m                    <i class="fas fa-user-tie"></i>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div>[m
[32m+[m[32m                    <h1 class="text-3xl font-bold text-gray-900 mb-2">[m
[32m+[m[32m                        <span id="greeting">[m
[32m+[m[32m                            {% now "H" as current_hour %}[m
[32m+[m[32m                            {% if current_hour|add:"0" < 12 %}Доброе утро[m
[32m+[m[32m                            {% elif current_hour|add:"0" < 18 %}Добрый день[m
[32m+[m[32m                            {% else %}Добрый вечер{% endif %}[m
[32m+[m[32m                        </span>, {{ user.get_full_name }}![m
[32m+[m[32m                    </h1>[m
[32m+[m[32m                    <div class="flex items-center space-x-6 text-sm text-gray-600">[m
[32m+[m[32m                        <div class="flex items-center space-x-2">[m
[32m+[m[32m                            <span class="status-indicator"></span>[m
[32m+[m[32m                            <span class="font-medium">Онлайн</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div id="current-datetime" class="flex items-center space-x-1">[m
[32m+[m[32m                            <i class="fas fa-clock"></i>[m
[32m+[m[32m                            <span>{% now "d.m.Y H:i" %}</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <button class="rt-button-outline">[m
[32m+[m[32m                <i class="fas fa-sign-out-alt mr-2"></i>Выйти[m
[32m+[m[32m            </button>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="notification-card rounded-xl p-6 mb-8">[m
[32m+[m[32m        <div class="flex items-center space-x-4">[m
[32m+[m[32m            <div class="rt-secondary w-12 h-12 rounded-xl flex items-center justify-center shadow-lg">[m
[32m+[m[32m                <i class="fas fa-info-circle text-xl"></i>[m
[32m+[m[32m            </div>[m
[32m+[m[32m            <div>[m
[32m+[m[32m                <h3 class="font-semibold text-blue-900 mb-2">Уведомление</h3>[m
[32m+[m[32m                <p class="text-blue-800 text-sm">Не забудьте отметить время прихода. У вас {{ available_days }} неиспользованных отпускных дней!</p>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <!-- Быстрые действия -->[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <h3 class="rt-section-title"><i class="fas fa-bolt"></i>Быстрые действия</h3>[m
[32m+[m[32m        <div class="grid grid-cols-2 md:grid-cols-4 gap-6">[m
[32m+[m[32m            <a href="{% url 'leave_request' %}" class="rt-quick-action">[m
[32m+[m[32m                <i class="fas fa-file-alt text-3xl"></i>[m
[32m+[m[32m                <p class="font-semibold text-gray-900">Новая заявка</p>[m
[32m+[m[32m            </a>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mb-8">[m
[32m+[m[32m        <div class="rt-stat-card">[m
[32m+[m[32m            <div class="rt-stat-icon"><i class="fas fa-check-circle"></i></div>[m
[32m+[m[32m            <p class="text-gray-600 text-sm mb-2 font-medium">Отработано дней</p>[m
[32m+[m[32m            <p class="text-3xl font-bold text-gray-900 mb-2">{{ worked_days }}</p>[m
[32m+[m[32m            <div class="rt-progress mt-3"><div class="rt-progress-bar" style="width: {{ progress_percentage }}%"></div></div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m        <div class="rt-stat-card">[m
[32m+[m[32m            <div class="rt-stat-icon blue"><i class="fas fa-clock"></i></div>[m
[32m+[m[32m            <p class="text-gray-600 text-sm mb-2 font-medium">Рабочих часов</p>[m
[32m+[m[32m            <p class="text-3xl font-bold text-gray-900 mb-2">{{ hours_planned }}</p>[m
[32m+[m[32m            <div class="rt-progress mt-3"><div class="rt-progress-bar" style="width: {{ hours_progress }}%"></div></div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m        <div class="rt-stat-card">[m
[32m+[m[32m            <div class="rt-stat-icon green"><i class="fas fa-umbrella-beach"></i></div>[m
[32m+[m[32m            <p class="text-gray-600 text-sm mb-2 font-medium">Отпускные дни</p>[m
[32m+[m[32m            <p class="text-3xl font-bold text-gray-900 mb-2">{{ available_days }}</p>[m
[32m+[m[32m            <div class="rt-progress mt-3"><div class="rt-progress-bar" style="width: {{ vacation_progress }}%"></div></div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m
[32m+[m[32m    <div class="mb-8">[m
[32m+[m[32m        <h3 class="rt-section-title"><i class="fas fa-paper-plane"></i>Последние заявки</h3>[m
[32m+[m[32m        <div class="space-y-4">[m
[32m+[m[32m            {% for request in my_requests %}[m
[32m+[m[32m                <div class="rt-request-card {{ request.status }}">[m
[32m+[m[32m                    <div class="flex items-center justify-between">[m
[32m+[m[32m                        <div class="flex items-center space-x-4">[m
[32m+[m[32m                            <div class="rt-stat-icon {{ request.status }}">[m
[32m+[m[32m                                {% if request.leave_type == 'vacation' %}<i class="fas fa-umbrella-beach"></i>[m
[32m+[m[32m                                {% elif request.leave_type == 'sick' %}<i class="fas fa-home"></i>[m
[32m+[m[32m                                {% else %}<i class="fas fa-suitcase"></i>{% endif %}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div>[m
[32m+[m[32m                                <p class="font-semibold text-gray-900">[m
[32m+[m[32m                                    {% if request.leave_type == 'vacation' %}Заявка на отпуск[m
[32m+[m[32m                                    {% elif request.leave_type == 'sick' %}Больничный[m
[32m+[m[32m                                    {% else %}Командировка{% endif %}[m
[32m+[m[32m                                </p>[m
[32m+[m[32m                                <p class="text-gray-500 text-sm">{{ request.start_date|date:"d.m.Y" }} - {{ request.end_date|date:"d.m.Y" }}</p>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <span class="text-{{ request.status }}-600 text-sm font-medium bg-{{ request.status }}-100 px-3 py-1 rounded-full">[m
[32m+[m[32m                            {% if request.status == 'pending' %}На рассмотрении[m
[32m+[m[32m                            {% elif request.status == 'approved' %}Одобрено[m
[32m+[m[32m                            {% else %}Отклонено{% endif %}[m
[32m+[m[32m                        </span>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            {% empty %}[m
[32m+[m[32m                <p class="text-gray-500">Нет недавних заявок.</p>[m
[32m+[m[32m            {% endfor %}[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m[32m</div>[m
[32m+[m[32m{% endblock %}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/templates/leave_request.html b/tabelTrack/app/templates/leave_request.html[m
[1mindex 6c1318a..fe6082a 100644[m
[1m--- a/tabelTrack/app/templates/leave_request.html[m
[1m+++ b/tabelTrack/app/templates/leave_request.html[m
[36m@@ -1,31 +1,395 @@[m
[31m-{% extends "base.html" %}[m
[32m+[m[32m{% extends 'base.html' %}[m
[32m+[m
 {% block content %}[m
[31m-<div class="max-w-2xl mx-auto p-6">[m
[31m-  <h2 class="text-2xl font-bold mb-4">Подать заявку на отпуск или больничный</h2>[m
[31m-  <p class="text-sm text-gray-500 mb-3">[m
[31m-    Остаток ежегодного отпуска: <span class="font-semibold">{{ available_days }}</span> дн.[m
[31m-  </p>  [m
[31m-  <form method="post" class="space-y-4">[m
[31m-    {% csrf_token %}[m
[31m-    {{ form.as_p }}[m
[31m-    <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">Отправить</button>[m
[31m-  </form>[m
[31m-[m
[31m-  <h3 class="text-xl font-semibold mt-8 mb-2">Мои заявки</h3>[m
[31m-  <ul class="space-y-2">[m
[31m-    {% for req in my_requests %}[m
[31m-      <li class="p-4 bg-white rounded shadow flex justify-between">[m
[31m-        <div>[m
[31m-          <p><strong>{{ req.get_leave_type_display }}:</strong> {{ req.start_date }} — {{ req.end_date }}</p>[m
[31m-          <p class="text-sm text-gray-500">{{ req.comment }}</p>[m
[32m+[m[32m<div class="min-h-screen bg-gray-50 py-6">[m
[32m+[m[32m    <div class="container mx-auto px-6 max-w-7xl">[m
[32m+[m[32m        <!-- Header Section -->[m
[32m+[m[32m        <div class="bg-white rounded-xl shadow-sm p-6 mb-8 border border-gray-100">[m
[32m+[m[32m            <div class="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-4">[m
[32m+[m[32m                <div class="flex items-center space-x-4">[m
[32m+[m[32m                    <div class="w-14 h-14 bg-gradient-to-br from-red-500 to-red-600 rounded-xl flex items-center justify-center text-white shadow-lg">[m
[32m+[m[32m                        <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>[m
[32m+[m[32m                        </svg>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <div>[m
[32m+[m[32m                        <h1 class="text-2xl font-bold text-gray-900">📝 Подача заявок</h1>[m
[32m+[m[32m                        <p class="text-gray-600">Отпуск, больничный и другие заявки</p>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="flex items-center space-x-3">[m
[32m+[m[32m                    <div class="bg-blue-50 text-blue-700 px-4 py-2 rounded-xl text-sm font-semibold border border-blue-200">[m
[32m+[m[32m                        <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3a2 2 0 012-2h4a2 2 0 012 2v4m-6 0h6l2 13H6l2-13z"/>[m
[32m+[m[32m                        </svg>[m
[32m+[m[32m                        Остаток: {{ available_days }} дней[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <a href="{% url 'dashboard' %}" class="bg-gray-100 text-gray-700 px-4 py-2 rounded-xl hover:bg-gray-200 transition-colors font-medium">[m
[32m+[m[32m                        <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>[m
[32m+[m[32m                        </svg>[m
[32m+[m[32m                        Назад[m
[32m+[m[32m                    </a>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">[m
[32m+[m[32m            <!-- Form Section -->[m
[32m+[m[32m            <div class="lg:col-span-2">[m
[32m+[m[32m                <div class="bg-white rounded-xl shadow-sm p-8 border border-gray-100">[m
[32m+[m[32m                    <div class="flex items-center space-x-4 mb-8">[m
[32m+[m[32m                        <div class="w-12 h-12 bg-red-50 rounded-xl flex items-center justify-center">[m
[32m+[m[32m                            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>[m
[32m+[m[32m                            </svg>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div>[m
[32m+[m[32m                            <h2 class="text-xl font-bold text-gray-900">Новая заявка</h2>[m
[32m+[m[32m                            <p class="text-gray-600">Заполните форму для подачи заявки</p>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m
[32m+[m[32m                    <form method="post" class="space-y-6">[m
[32m+[m[32m                        {% csrf_token %}[m
[32m+[m[32m                        {{ form.non_field_errors }}[m
[32m+[m[32m                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">[m
[32m+[m[32m                            <div class="space-y-2">[m
[32m+[m[32m                                <label class="block text-sm font-semibold text-gray-900">Тип заявки</label>[m
[32m+[m[32m                                {{ form.leave_type }}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="space-y-2">[m
[32m+[m[32m                                <label class="block text-sm font-semibold text-gray-900">Продолжительность</label>[m
[32m+[m[32m                                <div class="relative">[m
[32m+[m[32m                                    <input type="number" class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-colors" placeholder="Количество дней" min="1" id="id_days">[m
[32m+[m[32m                                    <div class="absolute inset-y-0 right-0 flex items-center pr-4 pointer-events-none">[m
[32m+[m[32m                                        <span class="text-gray-500 text-sm">дней</span>[m
[32m+[m[32m                                    </div>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m
[32m+[m[32m                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">[m
[32m+[m[32m                            <div class="space-y-2">[m
[32m+[m[32m                                <label class="block text-sm font-semibold text-gray-900">Дата начала</label>[m
[32m+[m[32m                                {{ form.start_date }}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="space-y-2">[m
[32m+[m[32m                                <label class="block text-sm font-semibold text-gray-900">Дата окончания</label>[m
[32m+[m[32m                                {{ form.end_date }}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m
[32m+[m[32m                        <div class="space-y-2">[m
[32m+[m[32m                            <label class="block text-sm font-semibold text-gray-900">Комментарий</label>[m
[32m+[m[32m                            {{ form.comment }}[m
[32m+[m[32m                        </div>[m
[32m+[m
[32m+[m[32m                        <div class="flex flex-col sm:flex-row gap-4 pt-4">[m
[32m+[m[32m                            <button type="submit" class="bg-green-600 text-white px-6 py-3 rounded-xl hover:bg-green-700 transition-colors font-semibold shadow-sm flex items-center justify-center space-x-2 flex-1 sm:flex-none">[m
[32m+[m[32m                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                                <span>Отправить заявку</span>[m
[32m+[m[32m                            </button>[m
[32m+[m[32m                            <button type="button" class="bg-gray-100 text-gray-700 px-6 py-3 rounded-xl hover:bg-gray-200 transition-colors font-semibold flex items-center justify-center space-x-2" id="save-draft">[m
[32m+[m[32m                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 0V6a2 2 0 00-2-2H9a2 2 0 00-2 2v1m1 0h4"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                                <span>Сохранить черновик</span>[m
[32m+[m[32m                            </button>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        {% if messages %}[m
[32m+[m[32m                        <div class="mt-4">[m
[32m+[m[32m                            {% for message in messages %}[m
[32m+[m[32m                            <div class="p-3 rounded-lg {% if message.tags == 'error' %}bg-red-100 text-red-700{% elif message.tags == 'success' %}bg-green-100 text-green-700{% elif message.tags == 'warning' %}bg-yellow-100 text-yellow-700{% endif %}">[m
[32m+[m[32m                                {{ message }}[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            {% endfor %}[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        {% endif %}[m
[32m+[m[32m                    </form>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Info Panel -->[m
[32m+[m[32m            <div class="space-y-6">[m
[32m+[m[32m                <!-- Quick Stats -->[m
[32m+[m[32m                <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">[m
[32m+[m[32m                    <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center">[m
[32m+[m[32m                        <div class="w-8 h-8 bg-red-50 rounded-lg flex items-center justify-center mr-3">[m
[32m+[m[32m                            <svg class="w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2-2V7a2 2 0 012-2h2a2 2 0 002 2v2a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 00-2 2h-2a2 2 0 00-2 2v6a2 2 0 01-2 2H9z"/>[m
[32m+[m[32m                            </svg>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        📊 Мой баланс[m
[32m+[m[32m                    </h3>[m
[32m+[m[32m                    <div class="space-y-4">[m
[32m+[m[32m                        <div class="flex justify-between items-center p-3 bg-green-50 rounded-lg">[m
[32m+[m[32m                            <div class="flex items-center space-x-2">[m
[32m+[m[32m                                <span class="text-green-600">🏖️</span>[m
[32m+[m[32m                                <span class="text-gray-700 font-medium">Ежегодный отпуск</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <span class="font-bold text-green-600">{{ available_days }} дней</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="flex justify-between items-center p-3 bg-blue-50 rounded-lg">[m
[32m+[m[32m                            <div class="flex items-center space-x-2">[m
[32m+[m[32m                                <span class="text-blue-600">🤒</span>[m
[32m+[m[32m                                <span class="text-gray-700 font-medium">Больничные</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <span class="font-bold text-blue-600">неогр.</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="flex justify-between items-center p-3 bg-yellow-50 rounded-lg">[m
[32m+[m[32m                            <div class="flex items-center space-x-2">[m
[32m+[m[32m                                <span class="text-yellow-600">👤</span>[m
[32m+[m[32m                                <span class="text-gray-700 font-medium">Отгулы</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <span class="font-bold text-yellow-600">2 дня</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="flex justify-between items-center p-3 bg-purple-50 rounded-lg">[m
[32m+[m[32m                            <div class="flex items-center space-x-2">[m
[32m+[m[32m                                <span class="text-purple-600">📚</span>[m
[32m+[m[32m                                <span class="text-gray-700 font-medium">Учебные</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <span class="font-bold text-purple-600">5 дней</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m
[32m+[m[32m                <!-- Tips -->[m
[32m+[m[32m                <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-100">[m
[32m+[m[32m                    <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center">[m
[32m+[m[32m                        <div class="w-8 h-8 bg-yellow-50 rounded-lg flex items-center justify-center mr-3">[m
[32m+[m[32m                            <svg class="w-4 h-4 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/>[m
[32m+[m[32m                            </svg>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        💡 Полезные советы[m
[32m+[m[32m                    </h3>[m
[32m+[m[32m                    <div class="space-y-4">[m
[32m+[m[32m                        <div class="flex items-start space-x-3 p-3 hover:bg-gray-50 rounded-lg transition-colors">[m
[32m+[m[32m                            <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">[m
[32m+[m[32m                                <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <p class="text-gray-700 text-sm">Подавайте заявку за 2 недели до нужной даты</p>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="flex items-start space-x-3 p-3 hover:bg-gray-50 rounded-lg transition-colors">[m
[32m+[m[32m                            <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">[m
[32m+[m[32m                                <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <p class="text-gray-700 text-sm">Для больничного прикрепите справку</p>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="flex items-start space-x-3 p-3 hover:bg-gray-50 rounded-lg transition-colors">[m
[32m+[m[32m                            <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">[m
[32m+[m[32m                                <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <p class="text-gray-700 text-sm">Учебный отпуск требует справку-вызов</p>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="flex items-start space-x-3 p-3 hover:bg-gray-50 rounded-lg transition-colors">[m
[32m+[m[32m                            <div class="w-5 h-5 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">[m
[32m+[m[32m                                <svg class="w-3 h-3 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>[m
[32m+[m[32m                                </svg>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <p class="text-gray-700 text-sm">Проверьте календарь корпоративных событий</p>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
         </div>[m
[31m-        <span class="{% if req.status == 'approved' %}text-green-600{% elif req.status == 'rejected' %}text-red-600{% else %}text-yellow-600{% endif %} font-bold">[m
[31m-          {{ req.get_status_display }}[m
[31m-        </span>[m
[31m-      </li>[m
[31m-    {% empty %}[m
[31m-      <p>Пока заявок нет.</p>[m
[31m-    {% endfor %}[m
[31m-  </ul>[m
[32m+[m
[32m+[m[32m        <!-- My Requests Section -->[m
[32m+[m[32m        <div class="mt-8">[m
[32m+[m[32m            <div class="bg-white rounded-xl shadow-sm p-8 border border-gray-100">[m
[32m+[m[32m                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">[m
[32m+[m[32m                    <h2 class="text-xl font-bold text-gray-900 flex items-center">[m
[32m+[m[32m                        <div class="w-8 h-8 bg-red-50 rounded-lg flex items-center justify-center mr-3">[m
[32m+[m[32m                            <svg class="w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>[m
[32m+[m[32m                            </svg>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        📋 Мои заявки[m
[32m+[m[32m                    </h2>[m
[32m+[m[32m                    <div class="flex items-center space-x-4">[m
[32m+[m[32m                        <span class="bg-red-50 text-red-700 px-4 py-2 rounded-xl text-sm font-semibold border border-red-200">[m
[32m+[m[32m                            {{ my_requests|length }} активные[m
[32m+[m[32m                        </span>[m
[32m+[m[32m                        <button class="text-blue-600 hover:text-blue-800 text-sm font-medium hover:underline transition-colors">[m
[32m+[m[32m                            Показать архив →[m
[32m+[m[32m                        </button>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m
[32m+[m[32m                <div class="space-y-4">[m
[32m+[m[32m                    {% for request in my_requests %}[m
[32m+[m[32m                    <div class="bg-{% if request.status == 'approved' %}green-50{% elif request.status == 'pending' %}yellow-50{% else %}red-50{% endif %} border border-{% if request.status == 'approved' %}green-200{% elif request.status == 'pending' %}yellow-200{% else %}red-200{% endif %} p-6 rounded-xl hover:shadow-md transition-all duration-200">[m
[32m+[m[32m                        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">[m
[32m+[m[32m                            <div class="flex items-center space-x-4">[m
[32m+[m[32m                                <div class="w-12 h-12 bg-{% if request.leave_type == 'vacation' %}green-100{% elif request.leave_type == 'sick' %}red-100{% elif request.leave_type == 'personal' %}yellow-100{% elif request.leave_type == 'study' %}purple-100{% else %}blue-100{% endif %} rounded-xl flex items-center justify-center">[m
[32m+[m[32m                                    <span class="text-{% if request.leave_type == 'vacation' %}green-600{% elif request.leave_type == 'sick' %}red-600{% elif request.leave_type == 'personal' %}yellow-600{% elif request.leave_type == 'study' %}purple-600{% else %}blue-600{% endif %} text-xl">[m
[32m+[m[32m                                        {% if request.leave_type == 'vacation' %}🏖️{% elif request.leave_type == 'sick' %}🤒{% elif request.leave_type == 'personal' %}👤{% elif request.leave_type == 'study' %}📚{% else %}👶{% endif %}[m
[32m+[m[32m                                    </span>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                                <div>[m
[32m+[m[32m                                    <h4 class="font-bold text-gray-900 mb-1">{{ request.get_leave_type_display }}</h4>[m
[32m+[m[32m                                    <p class="text-gray-600 text-sm">{{ request.start_date|date:"d.m.Y" }} — {{ request.end_date|date:"d.m.Y" }}</p>[m
[32m+[m[32m                                </div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="text-right">[m
[32m+[m[32m                                <span class="bg-{% if request.status == 'approved' %}green-100{% elif request.status == 'pending' %}yellow-100{% else %}red-100{% endif %} text-{% if request.status == 'approved' %}green-700{% elif request.status == 'pending' %}yellow-700{% else %}red-700{% endif %} px-3 py-1 rounded-full text-sm font-semibold inline-flex items-center">[m
[32m+[m[32m                                    {% if request.status == 'pending' %}[m
[32m+[m[32m                                        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>[m
[32m+[m[32m                                        </svg>[m
[32m+[m[32m                                        На рассмотрении[m
[32m+[m[32m                                    {% elif request.status == 'approved' %}[m
[32m+[m[32m                                        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4"/>[m
[32m+[m[32m                                        </svg>[m
[32m+[m[32m                                        Одобрено[m
[32m+[m[32m                                    {% else %}[m
[32m+[m[32m                                        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">[m
[32m+[m[32m                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>[m
[32m+[m[32m                                        </svg>[m
[32m+[m[32m                                        Отклонено[m
[32m+[m[32m                                    {% endif %}[m
[32m+[m[32m                                </span>[m
[32m+[m[32m                                <p class="text-xs text-gray-500 mt-2">{{ request.created_at|timesince }} назад</p>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    {% empty %}[m
[32m+[m[32m                    <p class="text-gray-500">Нет заявок.</p>[m
[32m+[m[32m                    {% endfor %}[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
 </div>[m
[32m+[m
[32m+[m[32m<script>[m
[32m+[m[32m    // Form validation and interaction[m
[32m+[m[32m    document.addEventListener('DOMContentLoaded', function() {[m
[32m+[m[32m        const form = document.querySelector('form');[m
[32m+[m[32m        const typeSelect = document.querySelector('#id_leave_type');[m
[32m+[m[32m        const startDate = document.querySelector('#id_start_date');[m
[32m+[m[32m        const endDate = document.querySelector('#id_end_date');[m
[32m+[m[32m        const daysInput = document.querySelector('#id_days');[m
[32m+[m
[32m+[m[32m        // Auto-calculate end date when start date and days are set[m
[32m+[m[32m        function updateEndDate() {[m
[32m+[m[32m            if (startDate.value && daysInput && daysInput.value) {[m
[32m+[m[32m                const start = new Date(startDate.value);[m
[32m+[m[32m                const days = parseInt(daysInput.value) - 1; // -1 because start day counts[m
[32m+[m[32m                const end = new Date(start);[m
[32m+[m[32m                end.setDate(start.getDate() + days);[m
[32m+[m[32m                endDate.value = end.toISOString().split('T')[0];[m
[32m+[m[32m            }[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        // Auto-calculate days when both dates are set[m
[32m+[m[32m        function updateDays() {[m
[32m+[m[32m            if (startDate.value && endDate.value) {[m
[32m+[m[32m                const start = new Date(startDate.value);[m
[32m+[m[32m                const end = new Date(endDate.value);[m
[32m+[m[32m                const diffTime = Math.abs(end - start);[m
[32m+[m[32m                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;[m
[32m+[m[32m                if (daysInput && diffDays > 0) {[m
[32m+[m[32m                    daysInput.value = diffDays;[m
[32m+[m[32m                }[m
[32m+[m[32m            }[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        startDate.addEventListener('change', () => {[m
[32m+[m[32m            updateEndDate();[m
[32m+[m[32m            updateDays();[m
[32m+[m[32m        });[m
[32m+[m[32m        if (daysInput) daysInput.addEventListener('input', updateEndDate);[m
[32m+[m[32m        endDate.addEventListener('change', updateDays);[m
[32m+[m
[32m+[m[32m        // Form submission with improved feedback[m
[32m+[m[32m        form.addEventListener('submit', function(e) {[m
[32m+[m[32m            e.preventDefault();[m
[32m+[m
[32m+[m[32m            // Simple client-side validation[m
[32m+[m[32m            if (!typeSelect.value || !startDate.value || !endDate.value) {[m
[32m+[m[32m                showToast('Пожалуйста, заполните все обязательные поля', 'error');[m
[32m+[m[32m                return;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            // Submit form to server[m
[32m+[m[32m            const formData = new FormData(form);[m
[32m+[m[32m            fetch(form.action, {[m
[32m+[m[32m                method: 'POST',[m
[32m+[m[32m                body: formData,[m
[32m+[m[32m                headers: {[m
[32m+[m[32m                    'X-CSRFToken': document.querySelector('[name=csrfmiddlewaretoken]').value[m
[32m+[m[32m                }[m
[32m+[m[32m            })[m
[32m+[m[32m            .then(response => response.json())[m
[32m+[m[32m            .then(data => {[m
[32m+[m[32m                if (data.success) {[m
[32m+[m[32m                    showToast('Заявка успешно отправлена!', 'success');[m
[32m+[m[32m                    setTimeout(() => window.location.href = '{% url "dashboard" %}', 2000);[m
[32m+[m[32m                } else {[m
[32m+[m[32m                    showToast(data.error || 'Ошибка при отправке заявки', 'error');[m
[32m+[m[32m                }[m
[32m+[m[32m            })[m
[32m+[m[32m            .catch(() => showToast('Произошла ошибка сети', 'error'));[m
[32m+[m
[32m+[m[32m            const submitBtn = document.querySelector('button[type="submit"]');[m
[32m+[m[32m            const originalText = submitBtn.innerHTML;[m
[32m+[m
[32m+[m[32m            submitBtn.innerHTML = `[m
[32m+[m[32m                <svg class="w-5 h-5 animate-spin mr-2" fill="none" viewBox="0 0 24 24">[m
[32m+[m[32m                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>[m
[32m+[m[32m                    <path class="opacity-75" fill="currentColor" d="m4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>[m
[32m+[m[32m                </svg>[m
[32m+[m[32m                <span>Отправляем...</span>[m
[32m+[m[32m            `;[m
[32m+[m[32m            submitBtn.disabled = true;[m
[32m+[m[32m        });[m
[32m+[m
[32m+[m[32m        // Draft saving (placeholder)[m
[32m+[m[32m        document.querySelector('#save-draft').addEventListener('click', function() {[m
[32m+[m[32m            showToast('Функция сохранения черновика пока не реализована', 'info');[m
[32m+[m[32m        });[m
[32m+[m
[32m+[m[32m        // Toast notification function[m
[32m+[m[32m        function showToast(message, type = 'info') {[m
[32m+[m[32m            const toast = document.createElement('div');[m
[32m+[m[32m            toast.className = `fixed top-4 right-4 z-50 p-4 rounded-xl shadow-lg transform transition-all duration-300 translate-x-full ${[m
[32m+[m[32m                type === 'success' ? 'bg-green-500 text-white' :[m
[32m+[m[32m                type === 'error' ? 'bg-red-500 text-white' :[m
[32m+[m[32m                'bg-blue-500 text-white'[m
[32m+[m[32m            }`;[m
[32m+[m[32m            toast.textContent = message;[m
[32m+[m
[32m+[m[32m            document.body.appendChild(toast);[m
[32m+[m
[32m+[m[32m            setTimeout(() => {[m
[32m+[m[32m                toast.classList.remove('translate-x-full');[m
[32m+[m[32m            }, 100);[m
[32m+[m
[32m+[m[32m            setTimeout(() => {[m
[32m+[m[32m                toast.classList.add('translate-x-full');[m
[32m+[m[32m                setTimeout(() => {[m
[32m+[m[32m                    document.body.removeChild(toast);[m
[32m+[m[32m                }, 300);[m
[32m+[m[32m            }, 3000);[m
[32m+[m[32m        }[m
[32m+[m[32m    });[m
[32m+[m[32m</script>[m
[32m+[m
[32m+[m[32m{% block extra_head %}[m
[32m+[m[32m    {% load static %}[m
[32m+[m[32m    <link rel="stylesheet" href="{% static 'css/leave_request.css' %}">[m
 {% endblock %}[m
[32m+[m
[32m+[m[32m{% endblock %}[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/templates/profile.html b/tabelTrack/app/templates/profile.html[m
[1mnew file mode 100644[m
[1mindex 0000000..65e716c[m
[1m--- /dev/null[m
[1m+++ b/tabelTrack/app/templates/profile.html[m
[36m@@ -0,0 +1,770 @@[m
[32m+[m[32m<!DOCTYPE html>[m
[32m+[m[32m<html lang="ru">[m
[32m+[m[32m<head>[m
[32m+[m[32m    <meta charset="UTF-8">[m
[32m+[m[32m    <meta name="viewport" content="width=device-width, initial-scale=1.0">[m
[32m+[m[32m    <title>Профиль сотрудника</title>[m
[32m+[m[32m    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">[m
[32m+[m[32m    <style>[m
[32m+[m[32m        * {[m
[32m+[m[32m            margin: 0;[m
[32m+[m[32m            padding: 0;[m
[32m+[m[32m            box-sizing: border-box;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        body {[m
[32m+[m[32m            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;[m
[32m+[m[32m            background-color: #f5f6fa;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Profile Page Styles */[m
[32m+[m[32m        .profile-container {[m
[32m+[m[32m            padding: 24px;[m
[32m+[m[32m            background-color: #f5f6fa;[m
[32m+[m[32m            min-height: 100vh;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Header Section */[m
[32m+[m[32m        .profile-header {[m
[32m+[m[32m            background: white;[m
[32m+[m[32m            border-radius: 12px;[m
[32m+[m[32m            padding: 24px;[m
[32m+[m[32m            margin-bottom: 24px;[m
[32m+[m[32m            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .profile-greeting {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            justify-content: space-between;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .greeting-icon {[m
[32m+[m[32m            width: 60px;[m
[32m+[m[32m            height: 60px;[m
[32m+[m[32m            background: linear-gradient(135deg, #d32f2f, #f44336);[m
[32m+[m[32m            border-radius: 12px;[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            font-size: 24px;[m
[32m+[m[32m            margin-right: 20px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .greeting-content h1 {[m
[32m+[m[32m            font-size: 32px;[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            margin: 0 0 8px 0;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .profile-status {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            gap: 12px;[m
[32m+[m[32m            color: #7f8c8d;[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .status-indicator {[m
[32m+[m[32m            width: 8px;[m
[32m+[m[32m            height: 8px;[m
[32m+[m[32m            border-radius: 50%;[m
[32m+[m[32m            background-color: #27ae60;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .status-indicator.online {[m
[32m+[m[32m            background-color: #27ae60;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .status-indicator.offline {[m
[32m+[m[32m            background-color: #e74c3c;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .btn-edit {[m
[32m+[m[32m            background: #d32f2f;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            border: none;[m
[32m+[m[32m            padding: 12px 24px;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m            font-weight: 500;[m
[32m+[m[32m            cursor: pointer;[m
[32m+[m[32m            transition: all 0.3s ease;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .btn-edit:hover {[m
[32m+[m[32m            background: #b71c1c;[m
[32m+[m[32m            transform: translateY(-2px);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Info Cards Grid */[m
[32m+[m[32m        .profile-info-grid {[m
[32m+[m[32m            display: grid;[m
[32m+[m[32m            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));[m
[32m+[m[32m            gap: 24px;[m
[32m+[m[32m            margin-bottom: 32px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .info-card {[m
[32m+[m[32m            background: white;[m
[32m+[m[32m            border-radius: 12px;[m
[32m+[m[32m            padding: 24px;[m
[32m+[m[32m            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);[m
[32m+[m[32m            transition: all 0.3s ease;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .info-card:hover {[m
[32m+[m[32m            transform: translateY(-4px);[m
[32m+[m[32m            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .info-card.full-width {[m
[32m+[m[32m            grid-column: 1 / -1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .card-header {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            justify-content: space-between;[m
[32m+[m[32m            margin-bottom: 20px;[m
[32m+[m[32m            padding-bottom: 16px;[m
[32m+[m[32m            border-bottom: 2px solid #ecf0f1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .card-header h3 {[m
[32m+[m[32m            font-size: 18px;[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            margin: 0;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .card-icon {[m
[32m+[m[32m            width: 40px;[m
[32m+[m[32m            height: 40px;[m
[32m+[m[32m            background: linear-gradient(135deg, #d32f2f, #f44336);[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            font-size: 16px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Profile Avatar */[m
[32m+[m[32m        .profile-avatar {[m
[32m+[m[32m            position: relative;[m
[32m+[m[32m            width: 120px;[m
[32m+[m[32m            height: 120px;[m
[32m+[m[32m            margin: 0 auto 20px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .profile-avatar img {[m
[32m+[m[32m            width: 100%;[m
[32m+[m[32m            height: 100%;[m
[32m+[m[32m            border-radius: 50%;[m
[32m+[m[32m            object-fit: cover;[m
[32m+[m[32m            border: 4px solid #ecf0f1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .avatar-status {[m
[32m+[m[32m            position: absolute;[m
[32m+[m[32m            bottom: 8px;[m
[32m+[m[32m            right: 8px;[m
[32m+[m[32m            width: 24px;[m
[32m+[m[32m            height: 24px;[m
[32m+[m[32m            border-radius: 50%;[m
[32m+[m[32m            border: 3px solid white;[m
[32m+[m[32m            background-color: #27ae60;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Detail Rows */[m
[32m+[m[32m        .detail-row {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            justify-content: space-between;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            padding: 12px 0;[m
[32m+[m[32m            border-bottom: 1px solid #ecf0f1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .detail-row:last-child {[m
[32m+[m[32m            border-bottom: none;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .detail-row .label {[m
[32m+[m[32m            font-weight: 500;[m
[32m+[m[32m            color: #7f8c8d;[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .detail-row .value {[m
[32m+[m[32m            font-weight: 500;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m            text-align: right;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Work Statistics */[m
[32m+[m[32m        .stats-grid {[m
[32m+[m[32m            display: grid;[m
[32m+[m[32m            grid-template-columns: repeat(2, 1fr);[m
[32m+[m[32m            gap: 20px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-item {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            gap: 16px;[m
[32m+[m[32m            padding: 16px;[m
[32m+[m[32m            background: #f8f9fa;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            transition: all 0.3s ease;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-item:hover {[m
[32m+[m[32m            background: #e9ecef;[m
[32m+[m[32m            transform: scale(1.02);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-icon {[m
[32m+[m[32m            width: 48px;[m
[32m+[m[32m            height: 48px;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            font-size: 20px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-icon.work-days {[m
[32m+[m[32m            background: linear-gradient(135deg, #e74c3c, #c0392b);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-icon.work-hours {[m
[32m+[m[32m            background: linear-gradient(135deg, #3498db, #2980b9);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-icon.vacation-days {[m
[32m+[m[32m            background: linear-gradient(135deg, #f39c12, #e67e22);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-icon.active-requests {[m
[32m+[m[32m            background: linear-gradient(135deg, #9b59b6, #8e44ad);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-content {[m
[32m+[m[32m            flex: 1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-number {[m
[32m+[m[32m            font-size: 24px;[m
[32m+[m[32m            font-weight: 700;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            line-height: 1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-label {[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m            font-weight: 500;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            margin: 4px 0 2px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .stat-subtitle {[m
[32m+[m[32m            font-size: 12px;[m
[32m+[m[32m            color: #7f8c8d;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Manager Info */[m
[32m+[m[32m        .manager-info {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            gap: 20px;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .manager-avatar {[m
[32m+[m[32m            width: 80px;[m
[32m+[m[32m            height: 80px;[m
[32m+[m[32m            flex-shrink: 0;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .manager-avatar img {[m
[32m+[m[32m            width: 100%;[m
[32m+[m[32m            height: 100%;[m
[32m+[m[32m            border-radius: 50%;[m
[32m+[m[32m            object-fit: cover;[m
[32m+[m[32m            border: 3px solid #ecf0f1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .manager-details {[m
[32m+[m[32m            flex: 1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Activity List */[m
[32m+[m[32m        .activity-list {[m
[32m+[m[32m            max-height: 400px;[m
[32m+[m[32m            overflow-y: auto;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-item {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: flex-start;[m
[32m+[m[32m            gap: 16px;[m
[32m+[m[32m            padding: 16px 0;[m
[32m+[m[32m            border-bottom: 1px solid #ecf0f1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-item:last-child {[m
[32m+[m[32m            border-bottom: none;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-icon {[m
[32m+[m[32m            width: 40px;[m
[32m+[m[32m            height: 40px;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            font-size: 16px;[m
[32m+[m[32m            flex-shrink: 0;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-icon.work {[m
[32m+[m[32m            background: linear-gradient(135deg, #27ae60, #2ecc71);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-icon.vacation {[m
[32m+[m[32m            background: linear-gradient(135deg, #f39c12, #e67e22);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-icon.request {[m
[32m+[m[32m            background: linear-gradient(135deg, #3498db, #2980b9);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-icon.system {[m
[32m+[m[32m            background: linear-gradient(135deg, #9b59b6, #8e44ad);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-content {[m
[32m+[m[32m            flex: 1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-title {[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m            margin-bottom: 4px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-description {[m
[32m+[m[32m            color: #7f8c8d;[m
[32m+[m[32m            font-size: 13px;[m
[32m+[m[32m            margin-bottom: 4px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .activity-time {[m
[32m+[m[32m            color: #95a5a6;[m
[32m+[m[32m            font-size: 12px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .no-activity {[m
[32m+[m[32m            text-align: center;[m
[32m+[m[32m            padding: 40px;[m
[32m+[m[32m            color: #7f8c8d;[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .no-activity i {[m
[32m+[m[32m            display: block;[m
[32m+[m[32m            font-size: 48px;[m
[32m+[m[32m            margin-bottom: 12px;[m
[32m+[m[32m            opacity: 0.5;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Quick Actions */[m
[32m+[m[32m        .quick-actions {[m
[32m+[m[32m            background: white;[m
[32m+[m[32m            border-radius: 12px;[m
[32m+[m[32m            padding: 24px;[m
[32m+[m[32m            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .quick-actions h3 {[m
[32m+[m[32m            font-size: 18px;[m
[32m+[m[32m            font-weight: 600;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            margin: 0 0 20px 0;[m
[32m+[m[32m            padding-bottom: 16px;[m
[32m+[m[32m            border-bottom: 2px solid #ecf0f1;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .actions-grid {[m
[32m+[m[32m            display: grid;[m
[32m+[m[32m            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));[m
[32m+[m[32m            gap: 16px;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .action-btn {[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            gap: 12px;[m
[32m+[m[32m            padding: 16px;[m
[32m+[m[32m            background: #f8f9fa;[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            text-decoration: none;[m
[32m+[m[32m            color: #2c3e50;[m
[32m+[m[32m            font-weight: 500;[m
[32m+[m[32m            font-size: 14px;[m
[32m+[m[32m            transition: all 0.3s ease;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .action-btn:hover {[m
[32m+[m[32m            background: #d32f2f;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            transform: translateY(-2px);[m
[32m+[m[32m            box-shadow: 0 4px 12px rgba(211, 47, 47, 0.3);[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .action-icon {[m
[32m+[m[32m            width: 40px;[m
[32m+[m[32m            height: 40px;[m
[32m+[m[32m            background: linear-gradient(135deg, #d32f2f, #f44336);[m
[32m+[m[32m            border-radius: 8px;[m
[32m+[m[32m            display: flex;[m
[32m+[m[32m            align-items: center;[m
[32m+[m[32m            justify-content: center;[m
[32m+[m[32m            color: white;[m
[32m+[m[32m            font-size: 16px;[m
[32m+[m[32m            transition: all 0.3s ease;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        .action-btn:hover .action-icon {[m
[32m+[m[32m            background: linear-gradient(135deg, #fff, #f8f9fa);[m
[32m+[m[32m            color: #d32f2f;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        /* Responsive Design */[m
[32m+[m[32m        @media (max-width: 768px) {[m
[32m+[m[32m            .profile-container {[m
[32m+[m[32m                padding: 16px;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .profile-greeting {[m
[32m+[m[32m                flex-direction: column;[m
[32m+[m[32m                align-items: flex-start;[m
[32m+[m[32m                gap: 16px;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .greeting-icon {[m
[32m+[m[32m                margin-right: 0;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .profile-info-grid {[m
[32m+[m[32m                grid-template-columns: 1fr;[m
[32m+[m[32m                gap: 16px;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .stats-grid {[m
[32m+[m[32m                grid-template-columns: 1fr;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .manager-info {[m
[32m+[m[32m                flex-direction: column;[m
[32m+[m[32m                text-align: center;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .actions-grid {[m
[32m+[m[32m                grid-template-columns: 1fr;[m
[32m+[m[32m            }[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        @media (max-width: 480px) {[m
[32m+[m[32m            .greeting-content h1 {[m
[32m+[m[32m                font-size: 24px;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .profile-status {[m
[32m+[m[32m                flex-wrap: wrap;[m
[32m+[m[32m                gap: 8px;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .card-header {[m
[32m+[m[32m                flex-direction: column;[m
[32m+[m[32m                align-items: flex-start;[m
[32m+[m[32m                gap: 12px;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .detail-row {[m
[32m+[m[32m                flex-direction: column;[m
[32m+[m[32m                align-items: flex-start;[m
[32m+[m[32m                gap: 4px;[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m            .detail-row .value {[m
[32m+[m[32m                text-align: left;[m
[32m+[m[32m            }[m
[32m+[m[32m        }[m
[32m+[m[32m    </style>[m
[32m+[m[32m</head>[m
[32m+[m[32m<body>[m
[32m+[m[32m    <div class="profile-container">[m
[32m+[m[32m        <!-- Header Section -->[m
[32m+[m[32m        <div class="profile-header">[m
[32m+[m[32m            <div class="profile-greeting">[m
[32m+[m[32m                <div class="greeting-icon">[m
[32m+[m[32m                    <i class="fas fa-user"></i>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="greeting-content">[m
[32m+[m[32m                    <h1>Профиль сотрудника</h1>[m
[32m+[m[32m                    <div class="profile-status">[m
[32m+[m[32m                        <span class="status-indicator online"></span>[m
[32m+[m[32m                        <span class="status-text">В работе</span>[m
[32m+[m[32m                        <span class="timestamp">13 июн 2025 г. в 14:30</span>[m
[32m+[m[32m                        <span class="location">IT отдел</span>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="header-actions">[m
[32m+[m[32m                    <button class="btn-edit">Редактировать</button>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        <!-- Profile Info Cards -->[m
[32m+[m[32m        <div class="profile-info-grid">[m
[32m+[m[32m            <!-- Personal Info Card -->[m
[32m+[m[32m            <div class="info-card">[m
[32m+[m[32m                <div class="card-header">[m
[32m+[m[32m                    <h3>Личная информация</h3>[m
[32m+[m[32m                    <div class="card-icon">[m
[32m+[m[32m                        <i class="fas fa-user-circle"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="card-content">[m
[32m+[m[32m                    <div class="profile-avatar">[m
[32m+[m[32m                        <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face" alt="Фото сотрудника">[m
[32m+[m[32m                        <div class="avatar-status online"></div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <div class="profile-details">[m
[32m+[m[32m                        <div class="detail-row">[m
[32m+[m[32m                            <span class="label">ФИО:</span>[m
[32m+[m[32m                            <span class="value">Петров Иван Сергеевич</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="detail-row">[m
[32m+[m[32m                            <span class="label">Должность:</span>[m
[32m+[m[32m                            <span class="value">Старший разработчик</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="detail-row">[m
[32m+[m[32m                            <span class="label">Подразделение:</span>[m
[32m+[m[32m                            <span class="value">IT отдел</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="detail-row">[m
[32m+[m[32m                            <span class="label">Табельный номер:</span>[m
[32m+[m[32m                            <span class="value">001234</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="detail-row">[m
[32m+[m[32m                            <span class="label">Дата приема:</span>[m
[32m+[m[32m                            <span class="value">15.03.2020</span>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Contact Info Card -->[m
[32m+[m[32m            <div class="info-card">[m
[32m+[m[32m                <div class="card-header">[m
[32m+[m[32m                    <h3>Контактная информация</h3>[m
[32m+[m[32m                    <div class="card-icon">[m
[32m+[m[32m                        <i class="fas fa-address-book"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="card-content">[m
[32m+[m[32m                    <div class="detail-row">[m
[32m+[m[32m                        <span class="label">Email:</span>[m
[32m+[m[32m                        <span class="value">i.petrov@company.com</span>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <div class="detail-row">[m
[32m+[m[32m                        <span class="label">Телефон:</span>[m
[32m+[m[32m                        <span class="value">+7 (999) 123-45-67</span>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <div class="detail-row">[m
[32m+[m[32m                        <span class="label">Внутренний номер:</span>[m
[32m+[m[32m                        <span class="value">1234</span>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <div class="detail-row">[m
[32m+[m[32m                        <span class="label">Адрес:</span>[m
[32m+[m[32m                        <span class="value">г. Москва, ул. Тверская, д. 12</span>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Work Statistics Card -->[m
[32m+[m[32m            <div class="info-card">[m
[32m+[m[32m                <div class="card-header">[m
[32m+[m[32m                    <h3>Статистика работы</h3>[m
[32m+[m[32m                    <div class="card-icon">[m
[32m+[m[32m                        <i class="fas fa-chart-bar"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="card-content">[m
[32m+[m[32m                    <div class="stats-grid">[m
[32m+[m[32m                        <div class="stat-item">[m
[32m+[m[32m                            <div class="stat-icon work-days">[m
[32m+[m[32m                                <i class="fas fa-calendar-check"></i>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="stat-content">[m
[32m+[m[32m                                <div class="stat-number">22</div>[m
[32m+[m[32m                                <div class="stat-label">Отработано дней</div>[m
[32m+[m[32m                                <div class="stat-subtitle">из 23 дней в месяце</div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="stat-item">[m
[32m+[m[32m                            <div class="stat-icon work-hours">[m
[32m+[m[32m                                <i class="fas fa-clock"></i>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="stat-content">[m
[32m+[m[32m                                <div class="stat-number">176</div>[m
[32m+[m[32m                                <div class="stat-label">Рабочих часов</div>[m
[32m+[m[32m                                <div class="stat-subtitle">из 184 часов</div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="stat-item">[m
[32m+[m[32m                            <div class="stat-icon vacation-days">[m
[32m+[m[32m                                <i class="fas fa-umbrella-beach"></i>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="stat-content">[m
[32m+[m[32m                                <div class="stat-number">12</div>[m
[32m+[m[32m                                <div class="stat-label">Отпускные дни</div>[m
[32m+[m[32m                                <div class="stat-subtitle">дней осталось</div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="stat-item">[m
[32m+[m[32m                            <div class="stat-icon active-requests">[m
[32m+[m[32m                                <i class="fas fa-file-alt"></i>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="stat-content">[m
[32m+[m[32m                                <div class="stat-number">3</div>[m
[32m+[m[32m                                <div class="stat-label">Активные заявки</div>[m
[32m+[m[32m                                <div class="stat-subtitle">в обработке</div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Manager Info Card -->[m
[32m+[m[32m            <div class="info-card">[m
[32m+[m[32m                <div class="card-header">[m
[32m+[m[32m                    <h3>Руководитель</h3>[m
[32m+[m[32m                    <div class="card-icon">[m
[32m+[m[32m                        <i class="fas fa-user-tie"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="card-content">[m
[32m+[m[32m                    <div class="manager-info">[m
[32m+[m[32m                        <div class="manager-avatar">[m
[32m+[m[32m                            <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&crop=face" alt="Фото руководителя">[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="manager-details">[m
[32m+[m[32m                            <div class="detail-row">[m
[32m+[m[32m                                <span class="label">ФИО:</span>[m
[32m+[m[32m                                <span class="value">Сидоров Алексей Петрович</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="detail-row">[m
[32m+[m[32m                                <span class="label">Должность:</span>[m
[32m+[m[32m                                <span class="value">Руководитель IT отдела</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="detail-row">[m
[32m+[m[32m                                <span class="label">Email:</span>[m
[32m+[m[32m                                <span class="value">a.sidorov@company.com</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="detail-row">[m
[32m+[m[32m                                <span class="label">Телефон:</span>[m
[32m+[m[32m                                <span class="value">+7 (999) 987-65-43</span>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m
[32m+[m[32m            <!-- Recent Activity Card -->[m
[32m+[m[32m            <div class="info-card full-width">[m
[32m+[m[32m                <div class="card-header">[m
[32m+[m[32m                    <h3>Последняя активность</h3>[m
[32m+[m[32m                    <div class="card-icon">[m
[32m+[m[32m                        <i class="fas fa-history"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="card-content">[m
[32m+[m[32m                    <div class="activity-list">[m
[32m+[m[32m                        <div class="activity-item">[m
[32m+[m[32m                            <div class="activity-icon work">[m
[32m+[m[32m                                <i class="fas fa-laptop-code"></i>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="activity-content">[m
[32m+[m[32m                                <div class="activity-title">Завершена задача по разработке</div>[m
[32m+[m[32m                                <div class="activity-description">Реализован новый модуль аутентификации пользователей</div>[m
[32m+[m[32m                                <div class="activity-time">13.06.2025 12:30</div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="activity-item">[m
[32m+[m[32m                            <div class="activity-icon request">[m
[32m+[m[32m                                <i class="fas fa-file-alt"></i>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="activity-content">[m
[32m+[m[32m                                <div class="activity-title">Подана заявка на отпуск</div>[m
[32m+[m[32m                                <div class="activity-description">Заявка на отпуск с 01.07.2025 по 14.07.2025</div>[m
[32m+[m[32m                                <div class="activity-time">12.06.2025 16:45</div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                        <div class="activity-item">[m
[32m+[m[32m                            <div class="activity-icon system">[m
[32m+[m[32m                                <i class="fas fa-cog"></i>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                            <div class="activity-content">[m
[32m+[m[32m                                <div class="activity-title">Обновление профиля</div>[m
[32m+[m[32m                                <div class="activity-description">Обновлены контактные данные</div>[m
[32m+[m[32m                                <div class="activity-time">10.06.2025 09:15</div>[m
[32m+[m[32m                            </div>[m
[32m+[m[32m                        </div>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m
[32m+[m[32m        <!-- Quick Actions -->[m
[32m+[m[32m        <div class="quick-actions">[m
[32m+[m[32m            <h3>Быстрые действия</h3>[m
[32m+[m[32m            <div class="actions-grid">[m
[32m+[m[32m                <a href="#" class="action-btn">[m
[32m+[m[32m                    <div class="action-icon">[m
[32m+[m[32m                        <i class="fas fa-calendar-alt"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <span>Мой табель</span>[m
[32m+[m[32m                </a>[m
[32m+[m[32m                <a href="#" class="action-btn">[m
[32m+[m[32m                    <div class="action-icon">[m
[32m+[m[32m                        <i class="fas fa-plus-circle"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <span>Новая заявка</span>[m
[32m+[m[32m                </a>[m
[32m+[m[32m                <a href="#" class="action-btn">[m
[32m+[m[32m                    <div class="action-icon">[m
[32m+[m[32m                        <i class="fas fa-umbrella-beach"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <span>Отпуска</span>[m
[32m+[m[32m                </a>[m
[32m+[m[32m                <a href="#" class="action-btn">[m
[32m+[m[32m                    <div class="action-icon">[m
[32m+[m[32m                        <i class="fas fa-chart-line"></i>[m
[32m+[m[32m                    </div>[m
[32m+[m[32m                    <span>Отчеты</span>[m
[32m+[m[32m                </a>[m
[32m+[m[32m            </div>[m
[32m+[m[32m        </div>[m
[32m+[m[32m    </div>[m
[32m+[m[32m</body>[m
[32m+[m[32m</html>[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/urls.py b/tabelTrack/app/urls.py[m
[1mindex cbe8efa..ebd0dff 100644[m
[1m--- a/tabelTrack/app/urls.py[m
[1m+++ b/tabelTrack/app/urls.py[m
[36m@@ -1,13 +1,32 @@[m
 from django.contrib import admin[m
 from django.urls import path, include[m
 from . import views[m
[32m+[m[32mfrom django.contrib.auth.decorators import login_required, user_passes_test[m
[32m+[m
[32m+[m[32m# Проверки ролей (уже определены в views.py)[m
[32m+[m[32mdef is_worker(user): return user.role == 'worker'[m
[32m+[m[32mdef is_editor(user): return user.role == 'editor'[m
[32m+[m[32mdef is_approver(user): return user.role == 'approver'[m
 [m
 urlpatterns = [[m
[31m-    path('', views.dashboard, name='dashboard'),[m
[31m-    path('attendance/', views.attendance, name='attendance'),[m
[31m-    path('leave/request/', views.leave_request, name='leave_request'),[m
[31m-    path('attendance/edit/', views.edit_attendance, name='edit_attendance'),[m
[31m-    path('leave/approve/', views.approve_requests, name='approve_requests'),[m
[31m-    path('admin/users/', views.user_management, name='user_management'),[m
[32m+[m[32m    # Главная страница (дашборд, адаптируется по роли)[m
[32m+[m[32m    path('', login_required(views.dashboard), name='dashboard'),[m
[32m+[m
[32m+[m[32m    # Посещаемость[m
[32m+[m[32m    path('attendance/', login_required(user_passes_test(is_worker)(views.attendance)), name='attendance'),[m
[32m+[m
[32m+[m[32m    # Подать заявку на отпуск/больничный[m
[32m+[m[32m    path('leave/request/', login_required(user_passes_test(is_worker)(views.leave_request)), name='leave_request'),[m
[32m+[m
[32m+[m[32m    # Редактирование табеля[m
[32m+[m[32m    path('attendance/edit/', login_required(user_passes_test(is_editor)(views.edit_attendance)), name='edit_attendance'),[m
[32m+[m
[32m+[m[32m    # Согласование заявок[m
[32m+[m[32m    path('leave/approve/', login_required(user_passes_test(is_approver)(views.approve_requests)), name='approve_requests'),[m
[32m+[m
[32m+[m[32m    # Управление пользователями (для админа)[m
[32m+[m[32m    path('admin/users/', login_required(user_passes_test(lambda u: u.role == 'admin')(views.user_management)), name='user_management'),[m
[32m+[m
[32m+[m[32m    # Аутентификация[m
     path('accounts/', include('django.contrib.auth.urls')),[m
[31m-][m
[32m+[m[32m][m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/app/utils/__init__.py b/tabelTrack/app/utils/__init__.py[m
[1mnew file mode 100644[m
[1mindex 0000000..e69de29[m
[1mdiff --git a/tabelTrack/utils/holidays.py b/tabelTrack/app/utils/holidays.py[m
[1msimilarity index 100%[m
[1mrename from tabelTrack/utils/holidays.py[m
[1mrename to tabelTrack/app/utils/holidays.py[m
[1mdiff --git a/tabelTrack/app/views.py b/tabelTrack/app/views.py[m
[1mindex 808c037..2257ea8 100644[m
[1m--- a/tabelTrack/app/views.py[m
[1m+++ b/tabelTrack/app/views.py[m
[36m@@ -1,13 +1,15 @@[m
 from datetime import date[m
 from calendar import monthrange[m
[31m-from django.shortcuts import render, redirect[m
[32m+[m[32mfrom django.shortcuts import redirect, render[m
 from django.contrib.auth.decorators import login_required, user_passes_test[m
[31m-from .forms import LeaveRequestForm[m
[31m-from .models import LeaveRequest, CustomUser[m
[31m-from django.utils.timezone import now[m
[32m+[m[32mfrom django.http import JsonResponse[m
 from django.contrib import messages[m
[32m+[m[32mfrom django.utils import timezone[m
[32m+[m[32mfrom django.conf import settings[m
[32m+[m[32mfrom .models import CustomUser, LeaveRequest[m
[32m+[m[32mfrom .forms import LeaveRequestForm[m
[32m+[m[32mfrom .utils.holidays import get_holidays_from_api[m
 from django.db.models import Q[m
[31m-from utils.holidays import get_holidays_from_api[m
 [m
 # Проверки ролей[m
 def is_worker(user): return user.role == 'worker'[m
[36m@@ -15,17 +17,15 @@[m [mdef is_editor(user): return user.role == 'editor'[m
 def is_approver(user): return user.role == 'approver'[m
 def is_admin(user): return user.role == 'admin'[m
 [m
[31m-[m
[31m-# Главная страница — доступна всем авторизованным[m
 @login_required[m
[31m-@user_passes_test(is_approver)[m
 def dashboard(request):[m
     today = date.today()[m
[32m+[m[32m    year = today.year[m
[32m+[m[32m    month = today.month[m
[32m+[m[32m    days_in_month = monthrange(year, month)[1][m
 [m
[31m-    # Список всех сотрудников[m
[32m+[m[32m    # Общие данные[m
     team_members = CustomUser.objects.filter(role='worker')[m
[31m-[m
[31m-    # Подсчёт общей статистики[m
     total_employees = team_members.count()[m
 [m
     # Заявки, перекрывающие сегодня[m
[36m@@ -34,12 +34,10 @@[m [mdef dashboard(request):[m
         start_date__lte=today,[m
         end_date__gte=today[m
     )[m
[31m-[m
     today_vacation = active_requests_today.filter(leave_type='vacation').count()[m
     today_sick = active_requests_today.filter(leave_type='sick').count()[m
     today_present = total_employees - today_vacation - today_sick[m
 [m
[31m-    # Статистика[m
     stats = {[m
         "today_present": today_present,[m
         "today_sick": today_sick,[m
[36m@@ -47,39 +45,149 @@[m [mdef dashboard(request):[m
         "total_employees": total_employees,[m
     }[m
 [m
[31m-    # Последние 5 заявок сотрудников[m
[31m-    team_requests = LeaveRequest.objects.filter([m
[31m-        user__role='worker'[m
[31m-    ).order_by('-created_at')[:5][m
[32m+[m[32m    # Личные данные текущего пользователя[m
[32m+[m[32m    user = request.user[m
[32m+[m[32m    my_requests = LeaveRequest.objects.filter(user=user).order_by('-created_at')[:5][m
[32m+[m[32m    total_used = sum((r.end_date - r.start_date).days + 1 for r in LeaveRequest.objects.filter([m
[32m+[m[32m        user=user, leave_type='vacation', status='approved'))[m
[32m+[m[32m    available_days = 44 - total_used[m
[32m+[m
[32m+[m[32m    # Календарь для текущего пользователя[m
[32m+[m[32m    gender = user.gender[m
[32m+[m[32m    shift = user.shift_type[m
[32m+[m[32m    shift_start = user.shift_start_date or date(2024, 1, 1)[m
[32m+[m[32m    holidays = get_holidays_from_api(year)[m
[32m+[m[32m    approved_requests = LeaveRequest.objects.filter([m
[32m+[m[32m        user=user,[m
[32m+[m[32m        status='approved',[m
[32m+[m[32m        start_date__lte=date(year, month, days_in_month),[m
[32m+[m[32m        end_date__gte=date(year, month, 1)[m
[32m+[m[32m    )[m
[32m+[m
[32m+[m[32m    calendar = [][m
[32m+[m[32m    first_weekday, _ = monthrange(year, month)[m
[32m+[m[32m    for _ in range(first_weekday):[m
[32m+[m[32m        calendar.append({'date': None, 'status': None, 'status_label': '', 'hours_planned': ''})[m
[32m+[m
[32m+[m[32m    for day in range(1, days_in_month + 1):[m
[32m+[m[32m        current_date = date(year, month, day)[m
[32m+[m[32m        weekday = current_date.weekday()[m
[32m+[m[32m        current_str = current_date.strftime('%Y-%m-%d')[m
[32m+[m
[32m+[m[32m        if current_str in holidays and holidays[current_str] == 'holiday':[m
[32m+[m[32m            status = 'holiday'[m
[32m+[m[32m        else:[m
[32m+[m[32m            status = None[m
[32m+[m[32m            for req in approved_requests:[m
[32m+[m[32m                if req.start_date <= current_date <= req.end_date:[m
[32m+[m[32m                    status = req.leave_type[m
[32m+[m[32m                    break[m
[32m+[m[32m            if not status:[m
[32m+[m[32m                if shift == '5_2':[m
[32m+[m[32m                    status = 'weekend' if weekday in [5, 6] else 'work'[m
[32m+[m[32m                elif shift == '2_2':[m
[32m+[m[32m                    index = (current_date - shift_start).days[m
[32m+[m[32m                    status = 'weekend' if index >= 0 and (index % 4) in [2, 3] else 'work'[m
[32m+[m[32m                elif shift == '1_3':[m
[32m+[m[32m                    index = (current_date - shift_start).days[m
[32m+[m[32m                    status = 'work' if index >= 0 and (index % 4) == 0 else 'weekend'[m
[32m+[m[32m                else:[m
[32m+[m[32m                    status = 'work'[m
[32m+[m
[32m+[m[32m        hours = 0[m
[32m+[m[32m        if status == 'work':[m
[32m+[m[32m            if shift == '5_2':[m
[32m+[m[32m                hours = 8 if gender == 'male' or weekday == 0 else 7[m
[32m+[m[32m            elif shift in ['2_2', '1_3']:[m
[32m+[m[32m                hours = 12[m
[32m+[m[32m            else:[m
[32m+[m[32m                hours = 8[m
[32m+[m
[32m+[m[32m        status_label = {[m
[32m+[m[32m            'work': 'Рабочий день',[m
[32m+[m[32m            'vacation': 'Отпуск',[m
[32m+[m[32m            'sick': 'Больничный',[m
[32m+[m[32m            'absent': 'Неявка',[m
[32m+[m[32m            'weekend': 'Выходной',[m
[32m+[m[32m            'holiday': 'Праздник 🎉',[m
[32m+[m[32m        }.get(status, 'Неизвестно')[m
 [m
[31m-    # По каждому сотруднику: сколько отработал, отпуск, больничный[m
[32m+[m[32m        calendar.append({[m
[32m+[m[32m            'date': current_date,[m
[32m+[m[32m            'status': status,[m
[32m+[m[32m            'status_label': status_label,[m
[32m+[m[32m            'hours_planned': hours[m
[32m+[m[32m        })[m
[32m+[m
[32m+[m[32m    # Подсчёт отработанных дней и прогресса для текущего пользователя[m
[32m+[m[32m    worked_days = sum(1 for day in calendar if day['status'] == 'work' and day['date'])[m
[32m+[m[32m    hours_planned = sum(day['hours_planned'] for day in calendar if day['status'] == 'work' and day['date'])[m
[32m+[m[32m    progress_percentage = (worked_days / days_in_month * 100) if days_in_month > 0 else 0[m
[32m+[m[32m    max_hours = days_in_month * 8  # Предполагаем 8 часов в день как максимум[m
[32m+[m[32m    hours_progress = (hours_planned / max_hours * 100) if max_hours > 0 else 0[m
[32m+[m[32m    vacation_progress = (available_days / 44 * 100) if 44 > 0 else 0[m
[32m+[m
[32m+[m[32m    # Все заявки для approver[m
[32m+[m[32m    all_requests = LeaveRequest.objects.filter(status__in=['pending', 'approved', 'rejected']).order_by('-created_at')[m
[32m+[m
[32m+[m[32m    # Детализация по сотрудникам для approver[m
     detailed_members = [][m
     for member in team_members:[m
         vacation = LeaveRequest.objects.filter(user=member, leave_type='vacation', status='approved')[m
         sick = LeaveRequest.objects.filter(user=member, leave_type='sick', status='approved')[m
[31m-[m
         vacation_days = sum((r.end_date - r.start_date).days + 1 for r in vacation)[m
         sick_days = sum((r.end_date - r.start_date).days + 1 for r in sick)[m
[31m-        absent_days = 0  # сюда можно добавить отсутствие без причины[m
[31m-[m
[31m-        # Для примера: считаем отработанные дни = общее кол-во рабочих дней - отпуск - больничный[m
[31m-        worked_days = 14  # ❗пока фиксированное число (можно связать с табелем)[m
[31m-[m
[32m+[m[32m        worked_days_member = sum(1 for day in calendar if day['status'] == 'work' and day['date'])[m
         detailed_members.append({[m
             'get_full_name': member.get_full_name(),[m
             'position': getattr(member, 'position', '—'),[m
             'vacation_days': vacation_days,[m
             'sick_days': sick_days,[m
[31m-            'worked_days': worked_days,[m
[32m+[m[32m            'worked_days': worked_days_member,[m
         })[m
 [m
[31m-    return render(request, 'dashboard.html', {[m
[31m-        'stats': stats,[m
[31m-        'team_requests': team_requests,[m
[31m-        'team_members': detailed_members,[m
[31m-        'user': request.user[m
[31m-    })[m
[31m-[m
[32m+[m[32m    # Выбор шаблона и данных в зависимости от роли[m
[32m+[m[32m    if is_worker(user):[m
[32m+[m[32m        return render(request, 'dashboard_worker.html', {[m
[32m+[m[32m            'my_requests': my_requests,[m
[32m+[m[32m            'worked_days': worked_days,[m
[32m+[m[32m            'hours_planned': hours_planned,[m
[32m+[m[32m            'available_days': available_days,[m
[32m+[m[32m            'progress_percentage': round(progress_percentage, 2),[m
[32m+[m[32m            'hours_progress': round(hours_progress, 2),[m
[32m+[m[32m            'vacation_progress': round(vacation_progress, 2),[m
[32m+[m[32m            'user': user,[m
[32m+[m[32m            'calendar': calendar,[m
[32m+[m[32m        })[m
[32m+[m[32m    elif is_approver(user):[m
[32m+[m[32m        return render(request, 'dashboard_approver.html', {[m
[32m+[m[32m            'my_requests': my_requests,[m
[32m+[m[32m            'worked_days': worked_days,[m
[32m+[m[32m            'hours_planned': hours_planned,[m
[32m+[m[32m            'available_days': available_days,[m
[32m+[m[32m            'progress_percentage': round(progress_percentage, 2),[m
[32m+[m[32m            'hours_progress': round(hours_progress, 2),[m
[32m+[m[32m            'vacation_progress': round(vacation_progress, 2),[m
[32m+[m[32m            'user': user,[m
[32m+[m[32m            'stats': stats,[m
[32m+[m[32m            'all_requests': all_requests,[m
[32m+[m[32m            'team_members': detailed_members,[m
[32m+[m[32m            'calendar': calendar,[m
[32m+[m[32m        })[m
[32m+[m[32m    elif is_editor(user):[m
[32m+[m[32m        return render(request, 'dashboard_editor.html', {[m
[32m+[m[32m            'my_requests': my_requests,[m
[32m+[m[32m            'worked_days': worked_days,[m
[32m+[m[32m            'hours_planned': hours_planned,[m
[32m+[m[32m            'available_days': available_days,[m
[32m+[m[32m            'progress_percentage': round(progress_percentage, 2),[m
[32m+[m[32m            'hours_progress': round(hours_progress, 2),[m
[32m+[m[32m            'vacation_progress': round(vacation_progress, 2),[m
[32m+[m[32m            'user': user,[m
[32m+[m[32m            'calendar': calendar,[m
[32m+[m[32m        })[m
[32m+[m[32m    else:[m
[32m+[m[32m        return render(request, 'dashboard.html', {'user': user})[m
 [m
 @login_required[m
 @user_passes_test(is_worker)[m
[36m@@ -175,8 +283,6 @@[m [mdef attendance(request):[m
         'weekdays': weekdays,[m
     })[m
 [m
[31m-[m
[31m-# Подача заявки — только сотрудник[m
 @login_required[m
 @user_passes_test(is_worker)[m
 def leave_request(request):[m
[36m@@ -185,7 +291,7 @@[m [mdef leave_request(request):[m
         if form.is_valid():[m
             leave = form.save(commit=False)[m
             leave.user = request.user[m
[31m-            leave.created_at = now()[m
[32m+[m[32m            leave.created_at = timezone.now()[m
 [m
             start = leave.start_date[m
             end = leave.end_date[m
[36m@@ -193,12 +299,12 @@[m [mdef leave_request(request):[m
 [m
             if start > end:[m
                 messages.error(request, "Дата начала не может быть позже даты окончания.")[m
[31m-                return redirect('leave_request')[m
[32m+[m[32m                return JsonResponse({'success': False, 'error': "Дата начала не может быть позже даты окончания."})[m
 [m
[31m-            # 1. Запрет отпуска задним числом (больничный — можно)[m
[32m+[m[32m            # 1. Запрет отпуска задним числом (кроме больничного)[m
             if leave_type != 'sick' and start < date.today():[m
                 messages.error(request, "Нельзя подавать заявку на отпуск задним числом.")[m
[31m-                return redirect('leave_request')[m
[32m+[m[32m                return JsonResponse({'success': False, 'error': "Нельзя подавать заявку на отпуск задним числом."})[m
 [m
             # 2. Проверка пересечений любых заявок[m
             overlapping = LeaveRequest.objects.filter([m
[36m@@ -210,7 +316,7 @@[m [mdef leave_request(request):[m
 [m
             if overlapping.exists():[m
                 messages.error(request, "У вас уже есть активная заявка, перекрывающая эти даты.")[m
[31m-                return redirect('leave_request')[m
[32m+[m[32m                return JsonResponse({'success': False, 'error': "У вас уже есть активная заявка, перекрывающая эти даты."})[m
 [m
             # 3. Лимит ежегодного отпуска[m
             requested_days = (end - start).days + 1[m
[36m@@ -228,7 +334,7 @@[m [mdef leave_request(request):[m
                 remaining = available_days - total_used[m
                 if requested_days > remaining:[m
                     messages.error(request, f"Превышен лимит отпуска. Осталось {remaining} дн.")[m
[31m-                    return redirect('leave_request')[m
[32m+[m[32m                    return JsonResponse({'success': False, 'error': f"Превышен лимит отпуска. Осталось {remaining} дн."})[m
 [m
                 if requested_days < 14:[m
                     messages.warning(request, "❗ По ТК РФ хотя бы одна часть отпуска должна быть не менее 14 дней.")[m
[36m@@ -248,14 +354,16 @@[m [mdef leave_request(request):[m
                         request,[m
                         f"{dict(LeaveRequest.TYPE_CHOICES)[leave_type]} не может пересекаться с {dict(LeaveRequest.TYPE_CHOICES)[opposite_type].lower()}."[m
                     )[m
[31m-                    return redirect('leave_request')[m
[32m+[m[32m                    return JsonResponse({'success': False, 'error': f"{dict(LeaveRequest.TYPE_CHOICES)[leave_type]} не может пересекаться с {dict(LeaveRequest.TYPE_CHOICES)[opposite_type].lower()}."})[m
 [m
             # 5. Статус: больничный — сразу approved[m
             leave.status = 'approved' if leave_type == 'sick' else 'pending'[m
 [m
             leave.save()[m
             messages.success(request, "Заявка успешно отправлена.")[m
[31m-            return redirect('dashboard')[m
[32m+[m[32m            return JsonResponse({'success': True})[m
[32m+[m[32m        else:[m
[32m+[m[32m            return JsonResponse({'success': False, 'error': form.errors.as_json()})[m
     else:[m
         form = LeaveRequestForm()[m
 [m
[36m@@ -278,8 +386,6 @@[m [mdef leave_request(request):[m
         'available_days': available_days[m
     })[m
 [m
[31m-[m
[31m-[m
 # Согласование заявок — только согласующий[m
 @login_required[m
 @user_passes_test(is_approver)[m
[36m@@ -291,7 +397,7 @@[m [mdef approve_requests(request):[m
         if leave.status == 'pending':[m
             leave.status = 'approved' if action == 'approve' else 'rejected'[m
             leave.reviewed_by = request.user[m
[31m-            leave.reviewed_at = now()[m
[32m+[m[32m            leave.reviewed_at = timezone.now()  # Исправлено с now() на timezone.now()[m
             leave.save()[m
             messages.success(request, f"Заявка была {'одобрена' if action == 'approve' else 'отклонена'}.")[m
 [m
[36m@@ -313,16 +419,14 @@[m [mdef approve_requests(request):[m
         'selected_type': leave_type_filter[m
     })[m
 [m
[31m-[m
 # Редактирование табеля — только редактор[m
 @login_required[m
 @user_passes_test(is_editor)[m
 def edit_attendance(request):[m
     return render(request, 'stub.html')[m
 [m
[31m-[m
 # Управление пользователями — только админ[m
 @login_required[m
 @user_passes_test(is_admin)[m
 def user_management(request):[m
[31m-    return render(request, 'stub.html')[m
[32m+[m[32m    return render(request, 'stub.html')[m
\ No newline at end of file[m
[1mdiff --git a/tabelTrack/tabelTrack/settings.py b/tabelTrack/tabelTrack/settings.py[m
[1mindex 176164d..660e290 100644[m
[1m--- a/tabelTrack/tabelTrack/settings.py[m
[1m+++ b/tabelTrack/tabelTrack/settings.py[m
[36m@@ -25,7 +25,11 @@[m [mSECRET_KEY = 'django-insecure-er_f6m*_@2xn#lk=b3_qy7e%^m)&si1%3-!k!^2%k6%%t)rn+b[m
 # SECURITY WARNING: don't run with debug turned on in production![m
 DEBUG = True[m
 [m
[31m-ALLOWED_HOSTS = [][m
[32m+[m[32mCSRF_TRUSTED_ORIGINS = [[m
[32m+[m[32m    'https://a88b-62-112-30-127.ngrok-free.app'[m
[32m+[m[32m][m
[32m+[m
[32m+[m[32mALLOWED_HOSTS = ['a88b-62-112-30-127.ngrok-free.app', '127.0.0.1'][m
 [m
 [m
 # Application definition[m
[36m@@ -127,3 +131,16 @@[m [mAUTH_USER_MODEL = 'app.CustomUser'[m
 LOGIN_REDIRECT_URL = '/'[m
 [m
 LOGOUT_REDIRECT_URL = '/accounts/login/'[m
[32m+[m
[32m+[m[32mLANGUAGE_CODE = 'ru'  # Устанавливаем русский язык по умолчанию[m
[32m+[m[32mTIME_ZONE = 'Europe/Moscow'  # Устанавливаем часовой пояс Москвы[m
[32m+[m[32mUSE_I18N = True  # Включаем использование локализации[m
[32m+[m[32mUSE_L10N = True  # Включаем локализацию данных (дат, чисел и т.д.)[m
[32m+[m
[32m+[m[32m# В settings.py[m
[32m+[m[32mEMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'[m
[32m+[m[32mEMAIL_HOST = 'smtp.gmail.com'[m
[32m+[m[32mEMAIL_PORT = 587[m
[32m+[m[32mEMAIL_USE_TLS = True[m
[32m+[m[32mEMAIL_HOST_USER = 'nurjjt@gmail.com'  # Замени на свой email[m
[41m+[m
