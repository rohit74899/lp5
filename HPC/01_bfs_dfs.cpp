#include <iostream>
#include <vector>
#include <queue>
#include <omp.h>
#include<ctime>
#include <chrono>
using namespace std::chrono;

using namespace std;

struct Graph {
    int V;
    vector<vector<int>> adj;

    Graph(int V) {
        this->V = V;
        adj.resize(V);
    }

    void addEdge(int u, int v) {
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    void BFS(int start) {
        vector<bool> visited(V, false);
        queue<int> q;
        visited[start] = true;
        q.push(start);

        while (!q.empty()) {
            int u = q.front();
            q.pop();
            cout << u << " ";

            #pragma omp parallel for
            for (int i = 0; i < adj[u].size(); i++) {
                int v = adj[u][i];
                if (!visited[v]) {
                    #pragma omp critical
                    {
                        visited[v] = true;
                        q.push(v);
                    }
                }
            }
        }
        cout << endl;
    }

    void DFS(int start) {
        vector<bool> visited(V, false);
        #pragma omp parallel
        {
            #pragma omp single nowait
            {
                DFSUtil(start, visited);
            }
        }
        cout << endl;
    }

    void DFSUtil(int u, vector<bool>& visited) {
        visited[u] = true;
        cout << u << " ";

        # pragma omp parallel for
        for (int i = 0; i < adj[u].size(); i++) {
            int v = adj[u][i];
            if (!visited[v]) {
                DFSUtil(v, visited);
            }
        }
    }
};

int main() {
    int V;
    cout << "Enter the number of vertices: ";
    cin >> V;

    Graph g(V);

    int edgeCount;
    cout << "Enter the number of edges: ";
    cin >> edgeCount;

    cout << "Enter the edges (in format 'source destination'): \n";
    for (int i = 0; i < edgeCount; i++) {
        int u, v;
        cin >> u >> v;
        g.addEdge(u, v);
    }

    cout << "BFS traversal starting from node 0: ";
    g.BFS(0);

    cout << "DFS traversal starting from node 0: ";
    g.DFS(0);

    return 0;


    auto startParallel = high_resolution_clock::now();

    // cudaDeviceSynchronize();
    auto stopParallel = high_resolution_clock::now();
    auto durationParallel = duration_cast<milliseconds>(stopParallel - startParallel);
    cout << "Parallel Execution Time: " << durationParallel.count() << " milliseconds" << endl;




    clock_t bubbleStart = clock();
    clock_t bubbleEnd = clock();
    double bubbleDuration = double(bubbleEnd-bubbleStart) / CLOCKS_PER_SEC;
}








// Ameya/////////////////////////////////////////////////////




// #include <iostream>
// #include <vector>
// #include <queue>
// #include <omp.h>

// using namespace std;

// // Graph class representing the adjacency list
// class Graph {
//     int V;  // Number of vertices
//     vector<vector<int>> adj;  // Adjacency list

// public:
//     Graph(int V) : V(V), adj(V) {}

//     // Add an edge to the graph
//     void addEdge(int v, int w) {
//         adj[v].push_back(w);
//     }

//     // Parallel Depth-First Search
//     void parallelDFS(int startVertex) {
//         vector<bool> visited(V, false);
//         parallelDFSUtil(startVertex, visited);
//     }

//     // Parallel DFS utility function
//     void parallelDFSUtil(int v, vector<bool>& visited) {
//         visited[v] = true;
//         cout << v << " ";

//         #pragma omp parallel for
//         for (int i = 0; i < adj[v].size(); ++i) {
//             int n = adj[v][i];
//             if (!visited[n])
//                 parallelDFSUtil(n, visited);
//         }
//     }

//     // Parallel Breadth-First Search
//     void parallelBFS(int startVertex) {
//         vector<bool> visited(V, false);
//         queue<int> q;

//         visited[startVertex] = true;
//         q.push(startVertex);

//         while (!q.empty()) {
//             int v = q.front();
//             q.pop();
//             cout << v << " ";

//             #pragma omp parallel for
//             for (int i = 0; i < adj[v].size(); ++i) {
//                 int n = adj[v][i];
//                 if (!visited[n]) {
//                     visited[n] = true;
//                     q.push(n);
//                 }
//             }
//         }
//     }
// };

// int main() {
//     // Create a graph
//     Graph g(7);
//     g.addEdge(0, 1);
//     g.addEdge(0, 2);
//     g.addEdge(1, 3);
//     g.addEdge(1, 4);
//     g.addEdge(2, 5);
//     g.addEdge(2, 6);
    
//     /*
//         0 -------->1
//         |         / \
//         |        /   \
//         |       /     \
//         v       v       v
//         2 ----> 3       4
//         |      |
//         |      |
//         v      v
//         5      6
//     */

//     cout << "Depth-First Search (DFS): ";
//     g.parallelDFS(0);
//     cout << endl;

//     cout << "Breadth-First Search (BFS): ";
//     g.parallelBFS(0);
//     cout << endl;   

//     return 0;
// }
