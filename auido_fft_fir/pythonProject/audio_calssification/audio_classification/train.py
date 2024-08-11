import os
import torch
from torch.utils.data import DataLoader, Dataset
from tqdm import tqdm
import resnet
import get_data
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
device = "cpu"
sound_model = resnet.ResNet().to(device)

batch_size = 16
learning_rate = 2e-4
train_dataset = get_data.BirdDataset()
train_loader = (DataLoader(train_dataset, batch_size=batch_size,shuffle=True,num_workers=0))

optimizer = torch.optim.AdamW(sound_model.parameters(), lr = learning_rate)
lr_scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer,T_max = 1600,eta_min=learning_rate/20,last_epoch=-1)
criterion = torch.nn.BCELoss()
# import focal_loss
# criterion = focal_loss.BCEFocalLoss()
criterion = torch.nn.CrossEntropyLoss()

for epoch in range(50):

    pbar = tqdm(train_loader,total=len(train_loader))
    for token_inp,token_tgt in pbar:
        token_inp = token_inp.to(device)
        token_tgt = token_tgt.to(device).float()

        logits = sound_model(token_inp)

        loss = criterion(logits, token_tgt)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        lr_scheduler.step()  # 执行优化器
        pbar.set_description(
            f"epoch:{epoch + 1}, train_loss:{loss.item():.5f}, lr:{lr_scheduler.get_last_lr()[0] * 1000:.5f}")
torch.save(sound_model.state_dict(),"./sound_model.pth")

