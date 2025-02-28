[... previous test content ...]

Clarinet.test({
  name: "Test meeting cancellation and overlap detection",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const organizer = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      // Add test cases for new functionality
      Tx.contractCall('pulse-sync', 'cancel-meeting', [
        types.uint(1)
      ], organizer.address),
      
      // Test overlap detection
      Tx.contractCall('pulse-sync', 'schedule-meeting', [
        types.ascii("Overlapping Meeting"),
        types.uint(1000),
        types.uint(1100),
        types.list([]),
        types.none(),
        types.list([])
      ], organizer.address)
    ]);
    
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectErr(107); // err-meeting-overlap
  },
});
