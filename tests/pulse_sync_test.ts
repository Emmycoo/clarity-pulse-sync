Clarinet.test({
  name: "Test enhanced meeting validation and history tracking",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const organizer = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      // Test maximum duration constraint
      Tx.contractCall('pulse-sync', 'schedule-meeting', [
        types.ascii("Long Meeting"),
        types.uint(1000),
        types.uint(2000), // Over 8 hours
        types.list([]),
        types.none(),
        types.list([types.uint(10)])
      ], organizer.address),
      
      // Test notification validation
      Tx.contractCall('pulse-sync', 'schedule-meeting', [
        types.ascii("Invalid Notification"),
        types.uint(1000),
        types.uint(1100),
        types.list([]),
        types.none(),
        types.list([types.uint(2)]) // Less than minimum
      ], organizer.address),
      
      // Test successful meeting creation
      Tx.contractCall('pulse-sync', 'schedule-meeting', [
        types.ascii("Valid Meeting"),
        types.uint(1000),
        types.uint(1100),
        types.list([]),
        types.none(),
        types.list([types.uint(10)])
      ], organizer.address)
    ]);
    
    block.receipts[0].result.expectErr(109); // err-invalid-duration
    block.receipts[1].result.expectErr(108); // err-invalid-notifications
    block.receipts[2].result.expectOk();
  },
});
