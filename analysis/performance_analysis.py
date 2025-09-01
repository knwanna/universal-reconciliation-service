import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import ttest_ind

# Sample data (replace with actual test results)
latencies = {
    'reconcile': [150, 200, 180, 220, 190, 210, 170, 230, 195, 205],
    'stream_chunk': [120, 130, 140, 110, 150, 125, 135, 145, 115, 130]
}
accuracies = {
    'reconcile': [0.95, 0.90, 0.92, 0.88, 0.94, 0.91, 0.89, 0.93, 0.90, 0.92],
    'stream_chunk': [0.85, 0.87, 0.90, 0.88, 0.86, 0.89, 0.87, 0.88, 0.86, 0.90]
}

# Statistical significance
reconcile_lat = latencies['reconcile']
stream_lat = latencies['stream_chunk']
t_stat_lat, p_value_lat = ttest_ind(reconcile_lat, stream_lat)
print(f"Latency T-test: t={t_stat_lat:.2f}, p={p_value_lat:.4f}")

reconcile_acc = accuracies['reconcile']
stream_acc = accuracies['stream_chunk']
t_stat_acc, p_value_acc = ttest_ind(reconcile_acc, stream_acc)
print(f"Accuracy T-test: t={t_stat_acc:.2f}, p={p_value_acc:.4f}")

# Visualizations
df_lat = pd.DataFrame({'Reconcile': reconcile_lat, 'Stream Chunk': stream_lat})
df_acc = pd.DataFrame({'Reconcile': accuracies['reconcile'], 'Stream Chunk': accuracies['stream_chunk']})

plt.figure(figsize=(12, 5))
plt.subplot(1, 2, 1)
sns.boxplot(data=df_lat)
plt.title('Latency Distribution (ms)')
plt.ylabel('Latency (ms)')
plt.subplot(1, 2, 2)
sns.boxplot(data=df_acc)
plt.title('Accuracy Distribution')
plt.ylabel('Accuracy')
plt.savefig('performance.png')
plt.show()

# Summary statistics
print("
Latency Summary:")
print(df_lat.describe())
print("
Accuracy Summary:")
print(df_acc.describe())
