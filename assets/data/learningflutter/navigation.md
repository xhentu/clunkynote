# Flutter Navigation Guide

## Types of Navigation Bars

| Navigation Type | Best Used For | Key Features |
| :--- | :--- | :--- |
| **NavigationBar** | Modern mobile bottom bar (Material 3 standard) | Smooth pill-shaped selection indicators, built-in height, uses `NavigationDestination` items. |
| **BottomNavigationBar** | Legacy mobile bottom bar (Material 2) | Traditional bottom bar, uses `BottomNavigationBarItem` items. |
| **NavigationRail** | Tablets, desktop, or wide screen layouts | Vertical side navigation bar, uses `NavigationRailDestination` items. |
| **TabBar** | Top-level content tabs (often inside `AppBar`) | Swipeable horizontal tabs synced with a `TabBarView`. Uses `Tab` items. |
| **NavigationDrawer** | Slide-out side drawer | Vertical list inside a hamburger menu or permanent side panel. Uses `NavigationDrawerDestination` items. |

## Core Properties (UI & State)

| Property | Type | What It Does |
| :--- | :--- | :--- |
| `selectedIndex` | `int` | Determines which destination is currently highlighted/active (e.g., 0, 1, 2). |
| `onDestinationSelected` | `ValueChanged<int>?` | A callback function triggered when a tab is tapped. Gives you the tapped index. |
| `destinations` | `List<Widget>` | The list of destination items (usually `NavigationDestination` widgets). |
| `indicatorColor` | `Color?` | Custom color for the pill-shaped highlight behind the selected icon. |
| `elevation` | `double?` | Controls the shadow elevation under the bar. |
| `backgroundColor` | `Color?` | Background color of the entire navigation container. |

---

## Simple NavigationBar Setup

### 1. The State Variable (Inside State Class)

~~~dart
int _selectedIndex = 0; // Tracks active tab (0 = first tab)
~~~

### 2. The Widget

~~~dart
NavigationBar(
  selectedIndex: _selectedIndex,   // Tells the bar WHICH item to highlight (0, 1, or 2)
  onDestinationSelected: (index) { // LISTENER: Fires when user taps an item
    setState(() => _selectedIndex = index);
  },
  destinations: [                  // LIST of item widgets
    NavigationDestination( ... ),  // Item 0
    NavigationDestination( ... ),  // Item 1
    NavigationDestination( ... ),  // Item 2
  ],
)
~~~

---

## Advanced Example: Data Model & Loop Generation

Using a custom model and a collection `for` loop keeps your code clean and scalable.

~~~dart
// 1. Define a simple Data Model or Class for menu items
class NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

// 2. Create your array/list of items
final List<NavItem> navItems = [
  const NavItem(
    label: 'Notes',
    icon: Icons.notes_outlined,
    selectedIcon: Icons.notes_rounded,
  ),
  const NavItem(
    label: 'Categories',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder_rounded,
  ),
  const NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  ),
];

// 3. Render the NavigationBar using a collection 'for' loop
NavigationBar(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (int index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  destinations: [
    // Collection 'for' iterates through the array directly inside the list
    for (final item in navItems)
      NavigationDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: item.label,
      ),
  ],
)
~~~

---

## Creating Child Elements (Switching Screens)

### Method A: Using IndexedStack (Preserves State)
This method keeps your screens alive in memory, so if a user scrolls down on the "Notes" screen, switches tabs, and comes back, they won't lose their scroll position.

~~~dart
// List of body screens matching the index order of your tabs
final List<Widget> _screens = [
  const NotesScreen(),      // Screen for index 0
  const CategoriesScreen(), // Screen for index 1
  const SettingsScreen(),   // Screen for index 2
];

// Inside your Scaffold build method:
Scaffold(
  body: IndexedStack(
    index: _selectedIndex, // Displays _screens[_selectedIndex]
    children: _screens,
  ),
  bottomNavigationBar: NavigationBar( ... ),
);
~~~

### Method B: Direct Array Index Lookup (Rebuilds Screen)
This method fully recreates the widget when you navigate to it. Use this if you want the screen to refresh every time the user clicks its tab.

~~~dart
Scaffold(
  body: _screens[_selectedIndex], // Shows only the active widget from the array
  bottomNavigationBar: NavigationBar( ... ),
);
~~~

## Navigation Techniques & State Management

| Navigation Technique | What happens to the Screen? | Does it preserve state? | Real World Example |
| :--- | :--- | :--- | :--- |
| **Rebuilding** (`_screens[index]`) | Replaces old screen; destroys old widget from memory. | ❌ No (Resets to default state) | Webpage page refresh |
| **Tab Stack** (`IndexedStack`) | Hides inactive screens side-by-side at the root level. | ✅ Yes | Switching between Notes / Settings tabs |
| **Push Stack** (`Navigator.push`) | Layers a new full screen on top of the current screen. | ✅ Yes (Preserves the screen below) | Tapping a note to open its detail/editor view |